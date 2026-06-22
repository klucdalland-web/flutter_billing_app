import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';
import '../../../../core/theme/app_theme.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );
  bool _isScanned = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isScanned) return;
    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _isScanned = true;
        final hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator == true) {
          Vibration.vibrate();
        }

        if (mounted) {
          context.pop(barcode.rawValue);
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.4)),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Scanner',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: controller, onDetect: _onDetect),
          Container(color: Colors.black.withValues(alpha: 0.35)),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.accentColor, width: 2),
              ),
              child: Stack(
                children: [
                  _buildCorner(Alignment.topLeft),
                  _buildCorner(Alignment.topRight),
                  _buildCorner(Alignment.bottomLeft),
                  _buildCorner(Alignment.bottomRight),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Placez le code-barres dans le cadre',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border(
            top: (alignment == Alignment.topLeft || alignment == Alignment.topRight)
                ? const BorderSide(color: AppTheme.accentColor, width: 4)
                : BorderSide.none,
            bottom: (alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight)
                ? const BorderSide(color: AppTheme.accentColor, width: 4)
                : BorderSide.none,
            left: (alignment == Alignment.topLeft || alignment == Alignment.bottomLeft)
                ? const BorderSide(color: AppTheme.accentColor, width: 4)
                : BorderSide.none,
            right: (alignment == Alignment.topRight || alignment == Alignment.bottomRight)
                ? const BorderSide(color: AppTheme.accentColor, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
