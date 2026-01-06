package com.realitycheck.reality_check

import android.app.Activity
import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Process
import android.provider.Settings
import android.util.Base64
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import java.io.ByteArrayOutputStream
import java.util.Calendar

class UsageStatsPlugin private constructor(
    private val context: Context,
    private val activity: Activity,
    flutterEngine: FlutterEngine
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val methodChannel: MethodChannel
    private val eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    private val iconCache = mutableMapOf<String, String>()

    companion object {
        private const val METHOD_CHANNEL = "com.realitycheck/usage_stats"
        private const val EVENT_CHANNEL = "com.realitycheck/usage_updates"
        private var instance: UsageStatsPlugin? = null

        fun registerWith(flutterEngine: FlutterEngine, activity: Activity) {
            instance?.dispose()
            instance = UsageStatsPlugin(activity.applicationContext, activity, flutterEngine).apply {
                methodChannel.setMethodCallHandler(this)
                eventChannel.setStreamHandler(this)
            }
        }
    }

    init {
        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL
        )
        eventChannel = EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL
        )
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "hasUsagePermission" -> {
                result.success(hasUsageStatsPermission())
            }
            "requestUsagePermission" -> {
                requestUsageStatsPermission()
                result.success(null)
            }
            "getUsageStats" -> {
                val startTime = call.argument<Long>("startTime") ?: 0L
                val endTime = call.argument<Long>("endTime") ?: System.currentTimeMillis()
                scope.launch {
                    try {
                        val stats = getUsageStats(startTime, endTime)
                        result.success(stats)
                    } catch (e: Exception) {
                        result.error("USAGE_STATS_ERROR", e.message, null)
                    }
                }
            }
            "getInstalledApps" -> {
                scope.launch {
                    try {
                        val apps = getInstalledApps()
                        result.success(apps)
                    } catch (e: Exception) {
                        result.error("INSTALLED_APPS_ERROR", e.message, null)
                    }
                }
            }
            "getAppIcon" -> {
                val packageName = call.argument<String>("packageName")
                if (packageName == null) {
                    result.error("INVALID_ARGUMENT", "Package name required", null)
                    return
                }
                scope.launch {
                    try {
                        val icon = getAppIconBase64(packageName)
                        result.success(icon)
                    } catch (e: Exception) {
                        result.success(null)
                    }
                }
            }
            "getBatchAppIcons" -> {
                val packageNames = call.argument<List<String>>("packageNames")
                if (packageNames == null) {
                    result.error("INVALID_ARGUMENT", "Package names required", null)
                    return
                }
                scope.launch {
                    try {
                        val icons = getBatchAppIcons(packageNames)
                        result.success(icons)
                    } catch (e: Exception) {
                        result.error("BATCH_ICONS_ERROR", e.message, null)
                    }
                }
            }
            "getCurrentForegroundApp" -> {
                scope.launch {
                    try {
                        val app = getCurrentForegroundApp()
                        result.success(app)
                    } catch (e: Exception) {
                        result.success(null)
                    }
                }
            }
            "getTodayUsageStats" -> {
                scope.launch {
                    try {
                        val stats = getTodayUsageStats()
                        result.success(stats)
                    } catch (e: Exception) {
                        result.error("TODAY_STATS_ERROR", e.message, null)
                    }
                }
            }
            "getWeeklyUsageStats" -> {
                scope.launch {
                    try {
                        val stats = getWeeklyUsageStats()
                        result.success(stats)
                    } catch (e: Exception) {
                        result.error("WEEKLY_STATS_ERROR", e.message, null)
                    }
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                context.packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                context.packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun requestUsageStatsPermission() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        context.startActivity(intent)
    }

    private suspend fun getUsageStats(startTime: Long, endTime: Long): List<Map<String, Any?>> =
        withContext(Dispatchers.IO) {
            if (!hasUsageStatsPermission()) {
                return@withContext emptyList()
            }

            val usageStatsManager =
                context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            val stats = usageStatsManager.queryUsageStats(
                UsageStatsManager.INTERVAL_DAILY,
                startTime,
                endTime
            )

            val packageManager = context.packageManager
            val result = mutableListOf<Map<String, Any?>>()

            stats?.filter { it.totalTimeInForeground > 0 }
                ?.sortedByDescending { it.totalTimeInForeground }
                ?.forEach { stat ->
                    try {
                        val appInfo = packageManager.getApplicationInfo(stat.packageName, 0)
                        val appName = packageManager.getApplicationLabel(appInfo).toString()
                        val category = getCategoryForPackage(stat.packageName, appInfo)
                        val isProductive = isAppProductive(stat.packageName, category)

                        result.add(
                            mapOf(
                                "packageName" to stat.packageName,
                                "appName" to appName,
                                "totalTimeMs" to stat.totalTimeInForeground,
                                "lastUsed" to stat.lastTimeUsed,
                                "firstUsed" to stat.firstTimeStamp,
                                "category" to category,
                                "isProductive" to isProductive
                            )
                        )
                    } catch (e: PackageManager.NameNotFoundException) {
                        // App might be uninstalled, skip
                    }
                }

            result
        }

    private suspend fun getTodayUsageStats(): List<Map<String, Any?>> =
        withContext(Dispatchers.IO) {
            val calendar = Calendar.getInstance().apply {
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }
            val startTime = calendar.timeInMillis
            val endTime = System.currentTimeMillis()

            getUsageStats(startTime, endTime)
        }

    private suspend fun getWeeklyUsageStats(): List<Map<String, Any?>> =
        withContext(Dispatchers.IO) {
            val calendar = Calendar.getInstance().apply {
                add(Calendar.DAY_OF_YEAR, -7)
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }
            val startTime = calendar.timeInMillis
            val endTime = System.currentTimeMillis()

            getUsageStats(startTime, endTime)
        }

    private suspend fun getInstalledApps(): List<Map<String, Any?>> =
        withContext(Dispatchers.IO) {
            val packageManager = context.packageManager
            val intent = Intent(Intent.ACTION_MAIN, null).apply {
                addCategory(Intent.CATEGORY_LAUNCHER)
            }

            val apps = packageManager.queryIntentActivities(intent, 0)
            val result = mutableListOf<Map<String, Any?>>()

            apps.forEach { resolveInfo ->
                try {
                    val packageName = resolveInfo.activityInfo.packageName
                    val appInfo = packageManager.getApplicationInfo(packageName, 0)
                    val appName = packageManager.getApplicationLabel(appInfo).toString()
                    val category = getCategoryForPackage(packageName, appInfo)
                    val isProductive = isAppProductive(packageName, category)

                    result.add(
                        mapOf(
                            "packageName" to packageName,
                            "appName" to appName,
                            "category" to category,
                            "isProductive" to isProductive,
                            "isSystemApp" to ((appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0)
                        )
                    )
                } catch (e: Exception) {
                    // Skip apps that can't be queried
                }
            }

            result.sortedBy { it["appName"] as String }
        }

    private suspend fun getAppIconBase64(packageName: String): String? =
        withContext(Dispatchers.IO) {
            // Check cache first
            iconCache[packageName]?.let { return@withContext it }

            try {
                val packageManager = context.packageManager
                val drawable = packageManager.getApplicationIcon(packageName)
                val bitmap = drawableToBitmap(drawable, 96)
                val stream = ByteArrayOutputStream()
                bitmap.compress(Bitmap.CompressFormat.PNG, 90, stream)
                val base64 = Base64.encodeToString(stream.toByteArray(), Base64.NO_WRAP)

                // Cache the result
                iconCache[packageName] = base64
                base64
            } catch (e: Exception) {
                null
            }
        }

    private suspend fun getBatchAppIcons(packageNames: List<String>): Map<String, String?> =
        withContext(Dispatchers.IO) {
            val result = mutableMapOf<String, String?>()
            packageNames.forEach { packageName ->
                result[packageName] = getAppIconBase64(packageName)
            }
            result
        }

    private fun drawableToBitmap(drawable: Drawable, size: Int): Bitmap {
        if (drawable is BitmapDrawable && drawable.bitmap != null) {
            return Bitmap.createScaledBitmap(drawable.bitmap, size, size, true)
        }

        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        return bitmap
    }

    private suspend fun getCurrentForegroundApp(): Map<String, Any?>? =
        withContext(Dispatchers.IO) {
            if (!hasUsageStatsPermission()) {
                return@withContext null
            }

            val usageStatsManager =
                context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            val endTime = System.currentTimeMillis()
            val startTime = endTime - 60000 // Last minute

            val stats = usageStatsManager.queryUsageStats(
                UsageStatsManager.INTERVAL_DAILY,
                startTime,
                endTime
            )

            val recentApp = stats
                ?.filter { it.lastTimeUsed > 0 }
                ?.maxByOrNull { it.lastTimeUsed }

            recentApp?.let { stat ->
                try {
                    val packageManager = context.packageManager
                    val appInfo = packageManager.getApplicationInfo(stat.packageName, 0)
                    val appName = packageManager.getApplicationLabel(appInfo).toString()

                    mapOf(
                        "packageName" to stat.packageName,
                        "appName" to appName,
                        "lastUsed" to stat.lastTimeUsed
                    )
                } catch (e: PackageManager.NameNotFoundException) {
                    null
                }
            }
        }

    private fun getCategoryForPackage(packageName: String, appInfo: ApplicationInfo): String {
        // First check our predefined categories
        val predefinedCategory = getPredefinedCategory(packageName)
        if (predefinedCategory != null) {
            return predefinedCategory
        }

        // Use Android's category if available (API 26+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            return when (appInfo.category) {
                ApplicationInfo.CATEGORY_GAME -> "Gaming"
                ApplicationInfo.CATEGORY_AUDIO -> "Streaming"
                ApplicationInfo.CATEGORY_VIDEO -> "Streaming"
                ApplicationInfo.CATEGORY_IMAGE -> "Creative"
                ApplicationInfo.CATEGORY_SOCIAL -> "Social Media"
                ApplicationInfo.CATEGORY_NEWS -> "News"
                ApplicationInfo.CATEGORY_MAPS -> "Productivity"
                ApplicationInfo.CATEGORY_PRODUCTIVITY -> "Productivity"
                else -> "Other"
            }
        }

        return "Other"
    }

    private fun getPredefinedCategory(packageName: String): String? {
        return when (packageName) {
            // Social Media
            "com.instagram.android" -> "Social Media"
            "com.zhiliaoapp.musically", "com.ss.android.ugc.trill" -> "Social Media" // TikTok
            "com.google.android.youtube" -> "Social Media"
            "com.twitter.android", "com.twitter.android.lite" -> "Social Media"
            "com.snapchat.android" -> "Social Media"
            "com.facebook.katana", "com.facebook.lite" -> "Social Media"
            "com.reddit.frontpage" -> "Social Media"
            "com.whatsapp" -> "Social Media"
            "org.telegram.messenger" -> "Social Media"

            // Gaming - Priority apps
            "com.tencent.ig" -> "Gaming" // PUBG Mobile
            "com.pubg.imobile" -> "Gaming" // BGMI
            "com.activision.callofduty.shooter" -> "Gaming" // COD Mobile
            "com.dts.freefireth", "com.dts.freefiremax" -> "Gaming" // Free Fire
            "com.supercell.clashofclans" -> "Gaming" // Clash of Clans
            "com.miHoYo.GenshinImpact" -> "Gaming" // Genshin Impact
            "com.innersloth.spacemafia" -> "Gaming" // Among Us
            "com.roblox.client" -> "Gaming" // Roblox
            "com.mojang.minecraftpe" -> "Gaming" // Minecraft
            "com.supercell.clashroyale" -> "Gaming"
            "com.kiloo.subwaysurf" -> "Gaming"
            "com.king.candycrushsaga" -> "Gaming"
            "com.epicgames.fortnite" -> "Gaming"

            // Streaming
            "com.netflix.mediaclient" -> "Streaming"
            "com.amazon.avod.thirdpartyclient" -> "Streaming"
            "com.disney.disneyplus" -> "Streaming"
            "com.spotify.music" -> "Streaming"
            "tv.twitch.android.app" -> "Streaming"
            "com.hulu.plus" -> "Streaming"
            "com.hbo.hbonow" -> "Streaming"

            // Productivity
            "com.google.android.apps.docs" -> "Productivity"
            "com.google.android.apps.docs.editors.docs" -> "Productivity"
            "com.google.android.apps.docs.editors.sheets" -> "Productivity"
            "com.microsoft.office.word" -> "Productivity"
            "com.microsoft.office.excel" -> "Productivity"
            "com.microsoft.teams" -> "Productivity"
            "com.slack" -> "Productivity"
            "com.notion.id" -> "Productivity"
            "com.todoist" -> "Productivity"
            "com.duolingo" -> "Productivity"
            "com.linkedin.android" -> "Productivity"

            else -> null
        }
    }

    private fun isAppProductive(packageName: String, category: String): Boolean {
        // Predefined productive apps
        val productiveApps = setOf(
            "com.google.android.apps.docs",
            "com.google.android.apps.docs.editors.docs",
            "com.google.android.apps.docs.editors.sheets",
            "com.microsoft.office.word",
            "com.microsoft.office.excel",
            "com.microsoft.teams",
            "com.slack",
            "com.notion.id",
            "com.todoist",
            "com.duolingo",
            "com.linkedin.android"
        )

        if (packageName in productiveApps) {
            return true
        }

        return category == "Productivity"
    }

    fun sendUsageUpdate(data: List<Map<String, Any?>>) {
        scope.launch(Dispatchers.Main) {
            eventSink?.success(data)
        }
    }

    private fun dispose() {
        scope.cancel()
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        iconCache.clear()
    }
}
