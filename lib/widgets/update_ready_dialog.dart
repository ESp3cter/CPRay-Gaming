import 'dart:io';
import 'package:flutter/material.dart';
import '../models/update_info.dart';
import '../services/localization_service.dart';
import '../services/updater_service.dart';

class UpdateReadyDialog extends StatefulWidget {
  final UpdateInfo updateInfo;
  final File installerFile;

  const UpdateReadyDialog({
    super.key,
    required this.updateInfo,
    required this.installerFile,
  });

  @override
  State<UpdateReadyDialog> createState() => _UpdateReadyDialogState();
}

class _UpdateReadyDialogState extends State<UpdateReadyDialog> {
  bool _isInstalling = false;

  Future<void> _install() async {
    setState(() => _isInstalling = true);
    await UpdaterService.applyDownloadedUpdate(widget.installerFile);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: LocalizationService.direction,
      child: Dialog(
        backgroundColor: const Color(0xFF141726),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF00FF88), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF88).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF00FF88),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocalizationService.tr('update_ready_title'),
                          style: const TextStyle(
                            color: Color(0xFF00FF88),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${LocalizationService.tr('version')} ${widget.updateInfo.version}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                LocalizationService.tr('update_ready_desc'),
                style: const TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              if (widget.updateInfo.changelog.isNotEmpty) ...[
                Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0F1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF242A42)),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      widget.updateInfo.changelog,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isInstalling ? null : () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF7E8B9E),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        LocalizationService.tr('later'),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isInstalling ? null : _install,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00FF88),
                        foregroundColor: const Color(0xFF090A10),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _isInstalling
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF090A10)),
                            )
                          : const Icon(Icons.install_mobile_rounded, size: 18),
                      label: Text(
                        _isInstalling ? '...' : LocalizationService.tr('install_now'),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
