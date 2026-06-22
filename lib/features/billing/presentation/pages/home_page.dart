import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../billing/presentation/bloc/billing_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/cart_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    returnImage: false,
  );

  bool _isCameraOn = true;
  bool _isFlashOn = false;

  // Cooldown mapping to prevent rapid firing of the same barcode
  final Map<String, DateTime> _lastScanTimes = {};

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;
    final now = DateTime.now();

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final rawValue = barcode.rawValue!;

        // Cooldown logic: 2 seconds per identical barcode
        if (_lastScanTimes.containsKey(rawValue)) {
          final lastScan = _lastScanTimes[rawValue]!;
          if (now.difference(lastScan).inSeconds < 2) {
            continue;
          }
        }

        _lastScanTimes[rawValue] = now;

        // Vibrate
        final hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator == true) {
          Vibration.vibrate();
        }

        if (mounted) {
          context.read<BillingBloc>().add(ScanBarcodeEvent(rawValue));
        }
        break; // Process one barcode at a time per frame
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<BillingBloc, BillingState>(
        listenWhen: (previous, current) =>
            previous.error != current.error && current.error != null,
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Stack(
          children: [
            // SCANNER VIEW (TOP 50%)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.4,
              child: _buildScannerSection(),
            ),

            // BOTTOM PANEL (BOTTOM 50% + OVERLAP)
            Positioned(
              top: (MediaQuery.of(context).size.height * 0.4) - 24, // overlap
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomPanel(),
            ),
          ],
        ),
      ),
      bottomSheet:
          BlocBuilder<BillingBloc, BillingState>(builder: (context, state) {
        return PrimaryButton(
          onPressed: state.cartItems.isEmpty
              ? null
              : () async {
                  _scannerController.stop();
                  await context.push('/checkout');
                  if (_isCameraOn && mounted) _scannerController.start();
                },
          icon: Icons.payment,
          label: 'Valider la commande',
        );
      }),
    );
  }

  Widget _buildScannerSection() {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
          if (!_isCameraOn) _buildCameraOffState(),

          // Brand header
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.point_of_sale_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'ShopFlow',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                  ),
                ],
              ),
            ),
          ),

          // Overlay Actions (Top Right)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: Column(
              children: [
                _buildOverlayButton(
                  icon: Icons.settings,
                  onPressed: () async {
                    _scannerController.stop();
                    await context.push('/settings');
                    if (_isCameraOn && mounted) _scannerController.start();
                  },
                ),
                const SizedBox(height: 16),
                if (_isCameraOn)
                  _buildOverlayButton(
                    icon:
                        _isFlashOn ? Icons.flashlight_off : Icons.flashlight_on,
                    onPressed: () {
                      setState(() => _isFlashOn = !_isFlashOn);
                      _scannerController.toggleTorch();
                    },
                  ),
                if (_isCameraOn) const SizedBox(height: 16),
                _buildOverlayButton(
                  icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                  // color:  Colors.white24 ,
                  onPressed: () {
                    setState(() {
                      _isCameraOn = !_isCameraOn;
                    });
                    if (_isCameraOn) {
                      _scannerController.start();
                    } else {
                      _scannerController.stop();
                    }
                  },
                ),
              ],
            ),
          ),

          // Central Overlay Bounding Box
          if (_isCameraOn)
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    // Corners
                    _buildCorner(Alignment.topLeft),
                    _buildCorner(Alignment.topRight),
                    _buildCorner(Alignment.bottomLeft),
                    _buildCorner(Alignment.bottomRight),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraOffState() {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.videocam_off_rounded, color: Colors.white, size: 34),
          ),
          const SizedBox(height: 20),
          const Text(
            'Caméra désactivée',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Activez la caméra pour scanner les codes-barres automatiquement.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            ),
            icon: const Icon(Icons.videocam_rounded),
            label: const Text('Activer la caméra', style: TextStyle(fontWeight: FontWeight.w700)),
            onPressed: () {
              setState(() => _isCameraOn = true);
              _scannerController.start();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayButton(
      {required IconData icon, required VoidCallback onPressed, Color? color}) {
    return Container(
      width: 44,
      height: 44,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.5)),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildCorner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border(
            top: (alignment == Alignment.topLeft ||
                    alignment == Alignment.topRight)
                ? const BorderSide(color: AppTheme.accentColor, width: 4)
                : BorderSide.none,
            bottom: (alignment == Alignment.bottomLeft ||
                    alignment == Alignment.bottomRight)
                ? const BorderSide(color: AppTheme.accentColor, width: 4)
                : BorderSide.none,
            left: (alignment == Alignment.topLeft ||
                    alignment == Alignment.bottomLeft)
                ? const BorderSide(color: AppTheme.accentColor, width: 4)
                : BorderSide.none,
            right: (alignment == Alignment.topRight ||
                    alignment == Alignment.bottomRight)
                ? const BorderSide(color: AppTheme.accentColor, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.15))),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textPrimary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle indicator
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header
          BlocBuilder<BillingBloc, BillingState>(
            builder: (context, state) {
              final totalItems =
                  state.cartItems.fold<int>(0, (sum, i) => sum + i.quantity);
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Panier',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w800)),
                        Text('$totalItems article${totalItems > 1 ? 's' : ''}',
                            style: const TextStyle(
                                fontSize: 13, color: AppTheme.textSecondary)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('TOTAL',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textSecondary,
                                letterSpacing: 1.4)),
                        Text(
                          '₹${state.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryColor),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1),

          // List View
          Expanded(
            child: Stack(children: [
              BlocBuilder<BillingBloc, BillingState>(
                builder: (context, state) {
                  if (state.cartItems.isEmpty) {
                    return _buildEmptyCart();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.only(
                        left: 15, right: 15, top: 16, bottom: 100),
                    itemCount: state.cartItems.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = state.cartItems[index];
                      return _buildCartItemCard(context, item);
                    },
                  );
                },
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: AppTheme.accentGradient,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.shopping_bag_outlined, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text('Panier vide',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Scannez un produit avec la caméra pour l\'ajouter ici.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(
    BuildContext context,
    CartItem item,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 1,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${item.product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _circularIconButton(
                    icon: Icons.remove,
                    onPressed: () {
                      if (item.quantity > 1) {
                        context.read<BillingBloc>().add(UpdateQuantityEvent(
                            item.product.id, item.quantity - 1));
                      } else {
                        context
                            .read<BillingBloc>()
                            .add(RemoveProductFromCartEvent(item.product.id));
                      }
                    }),
                SizedBox(
                  width: 32,
                  child: Text(
                    '${item.quantity}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                _circularIconButton(
                    icon: Icons.add,
                    onPressed: () {
                      context.read<BillingBloc>().add(UpdateQuantityEvent(
                          item.product.id, item.quantity + 1));
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circularIconButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, size: 20, color: AppTheme.primaryDark),
      ),
    );
  }

  // A floating Details/Checkout Button at the very bottom
  // Added a Stack wrapper below to overlay this button
}
