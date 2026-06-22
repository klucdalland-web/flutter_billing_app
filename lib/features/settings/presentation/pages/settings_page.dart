import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:app_settings/app_settings.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../bloc/printer_bloc.dart';
import '../bloc/printer_event.dart';
import '../bloc/printer_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<PrinterBloc>().add(InitPrinterEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            leading: IconButton(
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
                child: SafeArea(
                  child: BlocBuilder<ShopBloc, ShopState>(
                    builder: (context, state) {
                      String shopName = 'Ma boutique';
                      String initials = 'MB';
                      if (state is ShopLoaded && state.shop.name.isNotEmpty) {
                        shopName = state.shop.name;
                        final parts = shopName.split(' ');
                        initials = parts
                            .take(2)
                            .map((p) => p.isNotEmpty ? p[0].toUpperCase() : '')
                            .join('');
                        if (initials.isEmpty) initials = 'S';
                      }

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white30, width: 2),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            shopName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ShopFlow POS',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 13,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader('Gestion'),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildListItem(
                        icon: Icons.inventory_2_outlined,
                        title: 'Produits',
                        subtitle: 'Stock et codes-barres',
                        onTap: () => context.push('/products'),
                      ),
                      const Divider(height: 1, indent: 72),
                      _buildListItem(
                        icon: Icons.storefront_outlined,
                        title: 'Boutique',
                        subtitle: 'Infos et adresse',
                        onTap: () => context.push('/shop'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Matériel'),
                BlocConsumer<PrinterBloc, PrinterState>(
                  listener: (context, state) {
                    if (state.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.errorMessage!)),
                      );
                    } else if (state.status == PrinterStatus.connected) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Imprimante connectée')),
                      );
                    }
                  },
                  builder: (context, state) {
                    return AppCard(
                      padding: EdgeInsets.zero,
                      child: _buildListItem(
                        icon: Icons.print_outlined,
                        title: 'Imprimante',
                        subtitleWidget: Row(
                          children: [
                            Text(
                              state.connectedMac != null
                                  ? (state.connectedName ?? 'Connectée')
                                  : 'Non connectée',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            if (state.connectedMac != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.successColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'OK',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.successColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailingWidget: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (state.status == PrinterStatus.scanning ||
                                state.status == PrinterStatus.connecting)
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            else
                              IconButton(
                                icon: const Icon(Icons.refresh_rounded),
                                onPressed: () =>
                                    context.read<PrinterBloc>().add(RefreshPrinterEvent()),
                                color: AppTheme.primaryColor,
                              ),
                            IconButton(
                              icon: const Icon(Icons.settings_outlined),
                              onPressed: () => AppSettings.openAppSettings(
                                type: AppSettingsType.bluetooth,
                              ),
                              color: AppTheme.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Pour connecter une imprimante, associez-la via Bluetooth puis appuyez sur Actualiser.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppTheme.textSecondary,
          letterSpacing: 1.4,
        ),
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? subtitleWidget,
    Widget? trailingWidget,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                  if (subtitleWidget != null) ...[
                    const SizedBox(height: 4),
                    subtitleWidget,
                  ],
                ],
              ),
            ),
            if (trailingWidget != null)
              trailingWidget
            else if (onTap != null)
              const Icon(Icons.chevron_right_rounded, color: AppTheme.borderColor),
          ],
        ),
      ),
    );
  }
}
