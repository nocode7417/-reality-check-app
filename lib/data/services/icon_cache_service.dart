import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'platform_channel_service.dart';

/// Service for caching app icons with multi-tier caching
/// Tier 1: Memory LRU cache (fast access)
/// Tier 2: File system cache (persistent)
/// Tier 3: Native fetch (PackageManager)
class IconCacheService {
  final PlatformChannelService _platformChannel;

  // Memory LRU cache with max size
  final _memoryCache = _LRUCache<String, Uint8List>(maxSize: 100);

  // Track pending fetches to avoid duplicate requests
  final Map<String, Future<Uint8List?>> _pendingFetches = {};

  // Cache directory
  Directory? _cacheDir;

  IconCacheService(this._platformChannel);

  /// Initialize the cache directory
  Future<void> initialize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory('${appDir.path}/icon_cache');
      if (!await _cacheDir!.exists()) {
        await _cacheDir!.create(recursive: true);
      }
    } catch (e) {
      // Fall back to memory-only caching
      _cacheDir = null;
    }
  }

  /// Get app icon with multi-tier caching
  Future<Uint8List?> getIcon(String packageName) async {
    // Tier 1: Check memory cache
    final memoryIcon = _memoryCache.get(packageName);
    if (memoryIcon != null) {
      return memoryIcon;
    }

    // Tier 2: Check file cache
    final fileIcon = await _getFromFileCache(packageName);
    if (fileIcon != null) {
      _memoryCache.put(packageName, fileIcon);
      return fileIcon;
    }

    // Check if already fetching
    if (_pendingFetches.containsKey(packageName)) {
      return _pendingFetches[packageName];
    }

    // Tier 3: Fetch from native
    final fetchFuture = _fetchAndCache(packageName);
    _pendingFetches[packageName] = fetchFuture;

    try {
      return await fetchFuture;
    } finally {
      _pendingFetches.remove(packageName);
    }
  }

  /// Fetch icon from native and cache it
  Future<Uint8List?> _fetchAndCache(String packageName) async {
    final icon = await _platformChannel.getAppIcon(packageName);
    if (icon != null) {
      // Cache in memory
      _memoryCache.put(packageName, icon);
      // Cache to file
      await _saveToFileCache(packageName, icon);
    }
    return icon;
  }

  /// Get icon from file cache
  Future<Uint8List?> _getFromFileCache(String packageName) async {
    if (_cacheDir == null) return null;

    try {
      final file = File('${_cacheDir!.path}/${_sanitizeFileName(packageName)}.png');
      if (await file.exists()) {
        return await file.readAsBytes();
      }
    } catch (e) {
      // File read failed
    }
    return null;
  }

  /// Save icon to file cache
  Future<void> _saveToFileCache(String packageName, Uint8List icon) async {
    if (_cacheDir == null) return;

    try {
      final file = File('${_cacheDir!.path}/${_sanitizeFileName(packageName)}.png');
      await file.writeAsBytes(icon);
    } catch (e) {
      // File write failed
    }
  }

  /// Cache icon directly (for batch loading)
  void cacheIcon(String packageName, Uint8List icon) {
    _memoryCache.put(packageName, icon);
    _saveToFileCache(packageName, icon);
  }

  /// Batch load icons for better performance in lists
  Future<Map<String, Uint8List>> batchLoadIcons(List<String> packageNames) async {
    final result = <String, Uint8List>{};
    final toFetch = <String>[];

    // Check caches first
    for (final packageName in packageNames) {
      final cached = _memoryCache.get(packageName);
      if (cached != null) {
        result[packageName] = cached;
      } else {
        final fileIcon = await _getFromFileCache(packageName);
        if (fileIcon != null) {
          _memoryCache.put(packageName, fileIcon);
          result[packageName] = fileIcon;
        } else {
          toFetch.add(packageName);
        }
      }
    }

    // Batch fetch remaining icons
    if (toFetch.isNotEmpty) {
      final fetched = await _platformChannel.getBatchAppIcons(toFetch);
      for (final entry in fetched.entries) {
        _memoryCache.put(entry.key, entry.value);
        await _saveToFileCache(entry.key, entry.value);
        result[entry.key] = entry.value;
      }
    }

    return result;
  }

  /// Preload icons for a list of package names
  Future<void> preloadIcons(List<String> packageNames) async {
    await batchLoadIcons(packageNames);
  }

  /// Clear memory cache
  void clearMemoryCache() {
    _memoryCache.clear();
  }

  /// Clear all caches
  Future<void> clearAllCaches() async {
    _memoryCache.clear();

    if (_cacheDir != null && await _cacheDir!.exists()) {
      try {
        await _cacheDir!.delete(recursive: true);
        await _cacheDir!.create();
      } catch (e) {
        // Delete failed
      }
    }
  }

  /// Get cache size info
  Future<CacheInfo> getCacheInfo() async {
    int fileCount = 0;
    int totalBytes = 0;

    if (_cacheDir != null && await _cacheDir!.exists()) {
      final files = _cacheDir!.listSync();
      fileCount = files.length;
      for (final file in files) {
        if (file is File) {
          totalBytes += await file.length();
        }
      }
    }

    return CacheInfo(
      memoryCacheSize: _memoryCache.length,
      fileCacheCount: fileCount,
      fileCacheSizeBytes: totalBytes,
    );
  }

  /// Sanitize package name for file system
  String _sanitizeFileName(String packageName) {
    return packageName.replaceAll(RegExp(r'[^\w.]'), '_');
  }
}

/// Cache info model
class CacheInfo {
  final int memoryCacheSize;
  final int fileCacheCount;
  final int fileCacheSizeBytes;

  CacheInfo({
    required this.memoryCacheSize,
    required this.fileCacheCount,
    required this.fileCacheSizeBytes,
  });

  String get fileCacheSizeFormatted {
    if (fileCacheSizeBytes < 1024) return '$fileCacheSizeBytes B';
    if (fileCacheSizeBytes < 1024 * 1024) {
      return '${(fileCacheSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileCacheSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Simple LRU cache implementation
class _LRUCache<K, V> {
  final int maxSize;
  final _cache = <K, V>{};

  _LRUCache({required this.maxSize});

  V? get(K key) {
    final value = _cache.remove(key);
    if (value != null) {
      _cache[key] = value; // Move to end (most recently used)
    }
    return value;
  }

  void put(K key, V value) {
    _cache.remove(key);
    _cache[key] = value;

    // Evict oldest entries if over max size
    while (_cache.length > maxSize) {
      _cache.remove(_cache.keys.first);
    }
  }

  bool containsKey(K key) => _cache.containsKey(key);

  void clear() => _cache.clear();

  int get length => _cache.length;
}
