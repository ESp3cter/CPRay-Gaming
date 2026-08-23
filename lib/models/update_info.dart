class UpdateInfo {
  final String version;
  final String releaseName;
  final String changelog;
  final String downloadUrl;
  final DateTime publishedAt;
  final bool hasUpdate;

  UpdateInfo({
    required this.version,
    required this.releaseName,
    required this.changelog,
    required this.downloadUrl,
    required this.publishedAt,
    this.hasUpdate = false,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json, String currentVersion) {
    final tagName = (json['tag_name'] as String? ?? 'v1.0.0').replaceAll('v', '');
    final assets = json['assets'] as List<dynamic>? ?? [];
    
    // Find installer asset (.exe or .msix or zip)
    String url = '';
    for (final asset in assets) {
      final name = (asset['name'] as String? ?? '').toLowerCase();
      if (name.endsWith('.exe') || name.endsWith('.zip')) {
        url = asset['browser_download_url'] as String? ?? '';
        break;
      }
    }

    if (url.isEmpty && json['html_url'] != null) {
      url = json['html_url'] as String;
    }

    final hasUpdate = _isNewer(tagName, currentVersion.replaceAll('v', ''));

    return UpdateInfo(
      version: tagName,
      releaseName: json['name'] as String? ?? tagName,
      changelog: json['body'] as String? ?? '',
      downloadUrl: url,
      publishedAt: DateTime.tryParse(json['published_at'] as String? ?? '') ?? DateTime.now(),
      hasUpdate: hasUpdate,
    );
  }

  static bool _isNewer(String remoteVer, String currentVer) {
    try {
      final rParts = remoteVer.split('.').map(int.parse).toList();
      final cParts = currentVer.split('.').map(int.parse).toList();

      for (int i = 0; i < 3; i++) {
        final r = i < rParts.length ? rParts[i] : 0;
        final c = i < cParts.length ? cParts[i] : 0;
        if (r > c) return true;
        if (r < c) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
