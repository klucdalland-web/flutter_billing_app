import 'package:shopflow_pos/core/theme/app_theme.dart';
import 'package:shopflow_pos/core/widgets/app_card.dart';
import 'package:shopflow_pos/core/widgets/app_page_header.dart';
import 'package:shopflow_pos/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../bloc/billing_bloc.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        context.read<BillingBloc>().add(ClearCartEvent());
        context.go('/');
      },
      child: Scaffold(
        appBar: AppPageHeader(
          title: 'Paiement',
          onBack: () {
            context.read<BillingBloc>().add(ClearCartEvent());
            context.go('/');
          },
        ),
        body: BlocConsumer<BillingBloc, BillingState>(
          listener: (context, state) {
            if (state.printSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reçu imprimé avec succès')),
              );
            }
          },
          builder: (context, billingState) {
            return BlocBuilder<ShopBloc, ShopState>(
              builder: (context, shopState) {
                String upiId = '';
                String shopName = 'Boutique';

                if (shopState is ShopLoaded) {
                  upiId = shopState.shop.upiId;
                  shopName = shopState.shop.name;
                }

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppCard(
                              padding: EdgeInsets.zero,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Table(
                                  border: const TableBorder(
                                    horizontalInside: BorderSide(color: AppTheme.borderColor),
                                  ),
                                  children: [
                                    TableRow(
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withValues(alpha: 0.06),
                                      ),
                                      children: [
                                        _buildHeaderCell('Produit', TextAlign.left),
                                        _buildHeaderCell('Prix', TextAlign.right),
                                        _buildHeaderCell('Total', TextAlign.right),
                                      ],
                                    ),
                                    ...billingState.cartItems.map((item) {
                                      return TableRow(
                                        children: [
                                          _buildDataCell(
                                            '${item.quantity} × ${item.product.name}',
                                            TextAlign.left,
                                          ),
                                          _buildDataCell(
                                            '₹${item.product.price.toStringAsFixed(2)}',
                                            TextAlign.right,
                                            isSubtitle: true,
                                          ),
                                          _buildDataCell(
                                            '₹${item.total.toStringAsFixed(2)}',
                                            TextAlign.right,
                                            isBold: true,
                                          ),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                            if (upiId.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              AppCard(
                                child: Column(
                                  children: [
                                    const Text(
                                      'Payer par QR code',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: AppTheme.borderColor),
                                      ),
                                      child: SizedBox(
                                        width: 180,
                                        height: 180,
                                        child: PrettyQrView.data(
                                          data:
                                              'upi://pay?pa=$upiId&pn=$shopName&am=${billingState.totalAmount.toStringAsFixed(2)}&cu=INR',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                        border: Border(
                          top: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.12)),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.textPrimary.withValues(alpha: 0.06),
                            blurRadius: 20,
                            offset: const Offset(0, -6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'TOTAL',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textSecondary,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                Text(
                                  '₹${billingState.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PrimaryButton(
                            onPressed: () {
                              if (shopState is ShopLoaded) {
                                context.read<BillingBloc>().add(
                                      PrintReceiptEvent(
                                        shopName: shopState.shop.name,
                                        address1: shopState.shop.addressLine1,
                                        address2: shopState.shop.addressLine2,
                                        phone: shopState.shop.phoneNumber,
                                        footer: shopState.shop.footerText,
                                      ),
                                    );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Infos boutique non chargées')),
                                );
                              }
                            },
                            label: 'Imprimer le reçu',
                            icon: Icons.print_rounded,
                            isLoading: billingState.isPrinting,
                            useAccent: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, TextAlign align) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Text(
        text.toUpperCase(),
        textAlign: align,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, TextAlign align,
      {bool isBold = false, bool isSubtitle = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: isSubtitle ? 12 : 14,
          fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
          color: isSubtitle ? AppTheme.textSecondary : AppTheme.textPrimary,
        ),
      ),
    );
  }
}
