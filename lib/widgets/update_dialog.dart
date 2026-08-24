import 'package:flutter/material.dart';
import '../models/update_info.dart';
import '../services/updater_service.dart';

class UpdateDialog extends StatefulWidget {
  final UpdateInfo updateInfo;

  const UpdateDialog({
    super.key,
    required this.updateInfo,
  });

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isDownloading = false;
  double _progress = 0.0;
  String _statusText = 'Ready to update';
  int _received = 0;
  int _total = 0;
  String? _errorMessage;

  Future<void> _startUpdate() async {
    setState(() {
      _isDownloading = true;
      _statusText = 'Downloading update package...';
      _errorMessage = null;
    });

    try {
      await UpdaterService.downloadAndApplyUpdate(
        downloadUrl: widget.updateInfo.downloadUrl,
        onProgress: (progress, received, total) {
          if (mounted) {
            setState(() {
              _progress = progress;
              _received = received;
              _total = total;
              _statusText = 'Downloading: ${(progress * 100).toStringAsFixed(0)}% '
                  '(${(_received / (1024 * 1024)).toStringAsFixed(1)} MB / '
                  '${(_total / (1024 * 1024)).toStringAsFixed(1)} MB)';
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _errorMessage = 'Update failed: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF141726),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF00D4FF), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D4FF).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.system_update_rounded,
                    color: Color(0xFF00D4FF),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'NEW VERSION AVAILABLE',
                        style: TextStyle(
                          color: Color(0xFF00D4FF),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Version ${widget.updateInfo.version}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (!_isDownloading) ...[
              const Text(
                'What\'s New in this update:',
                style: TextStyle(
                  color: Color(0xFF8C9BAE),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 140),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0F1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF242A42)),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    widget.updateInfo.changelog.isNotEmpty
                        ? widget.updateInfo.changelog
                        : 'Updated Sing-box core engine, DNS fixes, and low-latency gaming routing.',
                    style: const TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Download Progress View
              Text(
                _statusText,
                style: const TextStyle(color: Color(0xFF00FF88), fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  backgroundColor: const Color(0xFF1E2438),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00D4FF)),
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'The app will automatically install and restart upon download completion.',
                style: TextStyle(color: Color(0xFF6B7A94), fontSize: 11),
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Color(0xFFFF3366), fontSize: 12),
              ),
            ],
            const SizedBox(height: 22),
            if (!_isDownloading)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Later',
                      style: TextStyle(color: Color(0xFF7E8B9E)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _startUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D4FF),
                      foregroundColor: const Color(0xFF0D0F18),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text(
                      'Update Now',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
