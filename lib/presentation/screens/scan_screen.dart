import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/providers.dart';

class ScanScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const ScanScreen({super.key, required this.sessionId});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool isProcessing = false;
  String? lastScannedId;

  final RegExp qrRegex = RegExp(r'^[A-Z]{2,5}-[0-9]{2}[A-Z]-[0-9]{3}$');

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null) {
        if (mounted) {
          setState(() {
            isProcessing = true;
            lastScannedId = code;
          });
        }

        if (qrRegex.hasMatch(code)) {
          final success = await ref
              .read(activeSessionAttendanceProvider(widget.sessionId).notifier)
              .addStudent(code);

          if (success) {
            HapticFeedback.mediumImpact(); // Vibration on success
            _showFeedback('Success: $code', Colors.green);
          } else {
            HapticFeedback.warningImpact(); // Vibration on duplicate
            _showFeedback('Already Scanned: $code', Colors.orange);
          }
        } else {
          HapticFeedback.errorImpact(); // Vibration on invalid
          _showFeedback('Invalid QR Format: $code', Colors.red);
        }

        // Delay to prevent rapid multiple scans
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          setState(() {
            isProcessing = false;
          });
        }
      }
    }
  }

  void _showFeedback(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          // Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: isProcessing ? Colors.blue : Colors.white, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Last scanned display
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Card(
              color: Colors.black54,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      isProcessing ? 'Processing...' : 'Ready to scan',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    if (lastScannedId != null)
                      Text(
                        'Last: $lastScannedId',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
