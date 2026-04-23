import 'package:flutter/material.dart';
import 'package:pos_final/core/theme/app_theme.dart';
import 'package:pos_final/locale/MyLocalizations.dart';
import 'package:pos_final/presentation/adaptive/adaptive_layout.dart';
import 'package:pos_final/presentation/desktop/layout/desktop_status_bar.dart';
import 'package:pos_final/presentation/screens/category_screen.dart';
import 'package:pos_final/presentation/screens/home_screen.dart';
import 'package:pos_final/presentation/screens/sales_screen.dart';
import 'package:pos_final/presentation/screens/contacts_screen.dart';
import 'package:pos_final/presentation/screens/expenses_screen.dart';
import 'package:pos_final/presentation/screens/shipment_screen.dart';
import 'package:pos_final/presentation/screens/follow_up_screen.dart';
import 'package:pos_final/presentation/screens/field_force_screen.dart';
import 'package:pos_final/presentation/screens/report_screen.dart';
import 'package:pos_final/presentation/screens/notification_screen.dart';

/// The navigation items shown in the desktop sidebar.
class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String labelKey;
  final String route;
  final Widget screen;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.labelKey,
    required this.route,
    required this.screen,
  });
}

final _navItems = [
  _NavItem(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
    labelKey: 'home',
    route: '/home',
    screen: const Home(),
  ),
  _NavItem(
    icon: Icons.category_outlined,
    selectedIcon: Icons.category_rounded,
    labelKey: 'Categories',
    route: '/Categories',
    screen: const CategoryScreen(),
  ),
  _NavItem(
    icon: Icons.bar_chart_outlined,
    selectedIcon: Icons.bar_chart_rounded,
    labelKey: 'sales',
    route: '/sale',
    screen: const Sales(),
  ),
  _NavItem(
    icon: Icons.people_outlined,
    selectedIcon: Icons.people_rounded,
    labelKey: 'contacts',
    route: '/leads',
    screen: const Contacts(),
  ),
  _NavItem(
    icon: Icons.receipt_long_outlined,
    selectedIcon: Icons.receipt_long_rounded,
    labelKey: 'expenses',
    route: '/expense',
    screen: const Expense(),
  ),
  _NavItem(
    icon: Icons.local_shipping_outlined,
    selectedIcon: Icons.local_shipping_rounded,
    labelKey: 'shipment',
    route: '/shipment',
    screen: const Shipment(),
  ),
  _NavItem(
    icon: Icons.event_note_outlined,
    selectedIcon: Icons.event_note_rounded,
    labelKey: 'follow_up',
    route: '/followUp',
    screen: const FollowUp(),
  ),
  _NavItem(
    icon: Icons.groups_outlined,
    selectedIcon: Icons.groups_rounded,
    labelKey: 'field_force',
    route: '/fieldForce',
    screen: const FieldForce(),
  ),
  _NavItem(
    icon: Icons.assessment_outlined,
    selectedIcon: Icons.assessment_rounded,
    labelKey: 'reports',
    route: ReportScreen.routeName,
    screen: const ReportScreen(),
  ),
];

/// Desktop navigation shell: NavigationRail (collapsed) at medium widths,
/// full NavigationDrawer (with labels) at expanded widths.
class DesktopShell extends StatefulWidget {
  const DesktopShell({super.key});

  @override
  State<DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends State<DesktopShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTheme = AppTheme.getCustomAppTheme(1);
    final bp = layoutBreakpoint(context);
    final bool showLabels = bp == LayoutBreakpoint.expanded;

    return Scaffold(
      backgroundColor: customTheme.bgLayer1,
      body: Column(
        children: [
          // Status bar always at top
          const DesktopStatusBar(),
          Expanded(
            child: Row(
              children: [
                // ---- Sidebar ----
                _buildSidebar(theme, customTheme, showLabels),
                // ---- Divider ----
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: customTheme.bgLayer4,
                ),
                // ---- Main content ----
                Expanded(
                  child: _navItems[_selectedIndex].screen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(
      ThemeData theme, CustomAppTheme customTheme, bool showLabels) {
    return Container(
      width: showLabels ? 200 : 72,
      color: customTheme.bgLayer2,
      child: Column(
        children: [
          // Logo / app header
          _SidebarHeader(expanded: showLabels),
          const SizedBox(height: 8),
          // Navigation items
          Expanded(
            child: ListView.builder(
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final selected = _selectedIndex == index;
                return _NavTile(
                  item: item,
                  selected: selected,
                  expanded: showLabels,
                  onTap: () => setState(() => _selectedIndex = index),
                );
              },
            ),
          ),
          // Bottom: Notifications + Settings
          _SidebarFooter(expanded: showLabels),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  final bool expanded;
  const _SidebarHeader({required this.expanded});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Icon(
            Icons.point_of_sale_rounded,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          if (expanded) ...[
            const SizedBox(width: 10),
            Text(
              'EazyERP',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.selected,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = AppLocalizations.of(context).translate(item.labelKey);

    return Tooltip(
      message: expanded ? '' : label,
      preferBelow: false,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                selected ? item.selectedIcon : item.icon,
                size: 20,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              if (expanded) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                      color: selected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.75),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  final bool expanded;
  const _SidebarFooter({required this.expanded});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const Divider(height: 1),
        _FooterTile(
          icon: Icons.notifications_outlined,
          label: 'Notifications',
          expanded: expanded,
          onTap: () => Navigator.pushNamed(context, '/notify'),
        ),
        _FooterTile(
          icon: Icons.settings_outlined,
          label: 'Settings',
          expanded: expanded,
          onTap: () {/* Phase 5: settings screen */},
        ),
      ],
    );
  }
}

class _FooterTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool expanded;
  final VoidCallback onTap;

  const _FooterTile({
    required this.icon,
    required this.label,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: expanded ? '' : label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: theme.colorScheme.onSurface.withOpacity(0.55),
              ),
              if (expanded) ...[
                const SizedBox(width: 12),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
