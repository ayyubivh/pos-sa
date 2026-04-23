import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Global keyboard shortcuts for the desktop POS.
///
/// Wrap the desktop shell with [DesktopShortcuts] to enable them.
/// Each shortcut dispatches a named route or calls a provided callback.
class DesktopShortcuts extends StatelessWidget {
  final Widget child;
  final VoidCallback? onNewSale;       // F1
  final VoidCallback? onCustomerSearch; // F2
  final VoidCallback? onProductSearch;  // F3
  final VoidCallback? onCheckout;       // F5
  final VoidCallback? onPrintLast;      // F7
  final VoidCallback? onCashDrawer;     // F8
  final VoidCallback? onReport;         // F10
  final VoidCallback? onFullscreen;     // F12

  const DesktopShortcuts({
    super.key,
    required this.child,
    this.onNewSale,
    this.onCustomerSearch,
    this.onProductSearch,
    this.onCheckout,
    this.onPrintLast,
    this.onCashDrawer,
    this.onReport,
    this.onFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.f1): _NewSaleIntent(),
        SingleActivator(LogicalKeyboardKey.f2): _CustomerSearchIntent(),
        SingleActivator(LogicalKeyboardKey.f3): _ProductSearchIntent(),
        SingleActivator(LogicalKeyboardKey.f5): _CheckoutIntent(),
        SingleActivator(LogicalKeyboardKey.f7): _PrintLastIntent(),
        SingleActivator(LogicalKeyboardKey.f8): _CashDrawerIntent(),
        SingleActivator(LogicalKeyboardKey.f10): _ReportIntent(),
        SingleActivator(LogicalKeyboardKey.f12): _FullscreenIntent(),
        SingleActivator(LogicalKeyboardKey.keyQ, control: true): _QuitIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _NewSaleIntent: CallbackAction<_NewSaleIntent>(
            onInvoke: (_) {
              onNewSale?.call();
              return null;
            },
          ),
          _CustomerSearchIntent: CallbackAction<_CustomerSearchIntent>(
            onInvoke: (_) {
              onCustomerSearch?.call();
              return null;
            },
          ),
          _ProductSearchIntent: CallbackAction<_ProductSearchIntent>(
            onInvoke: (_) {
              onProductSearch?.call();
              return null;
            },
          ),
          _CheckoutIntent: CallbackAction<_CheckoutIntent>(
            onInvoke: (_) {
              onCheckout?.call();
              return null;
            },
          ),
          _PrintLastIntent: CallbackAction<_PrintLastIntent>(
            onInvoke: (_) {
              onPrintLast?.call();
              return null;
            },
          ),
          _CashDrawerIntent: CallbackAction<_CashDrawerIntent>(
            onInvoke: (_) {
              onCashDrawer?.call();
              return null;
            },
          ),
          _ReportIntent: CallbackAction<_ReportIntent>(
            onInvoke: (_) {
              onReport?.call();
              return null;
            },
          ),
          _FullscreenIntent: CallbackAction<_FullscreenIntent>(
            onInvoke: (_) {
              onFullscreen?.call();
              return null;
            },
          ),
          _QuitIntent: CallbackAction<_QuitIntent>(
            onInvoke: (_) => _showQuitDialog(context),
          ),
        },
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }

  Future<void> _showQuitDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quit EazyERP POS?'),
        content: const Text('Any unsynced data will be saved locally.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Quit'),
          ),
        ],
      ),
    );
  }
}

// --- Intent definitions ---
class _NewSaleIntent extends Intent {
  const _NewSaleIntent();
}

class _CustomerSearchIntent extends Intent {
  const _CustomerSearchIntent();
}

class _ProductSearchIntent extends Intent {
  const _ProductSearchIntent();
}

class _CheckoutIntent extends Intent {
  const _CheckoutIntent();
}

class _PrintLastIntent extends Intent {
  const _PrintLastIntent();
}

class _CashDrawerIntent extends Intent {
  const _CashDrawerIntent();
}

class _ReportIntent extends Intent {
  const _ReportIntent();
}

class _FullscreenIntent extends Intent {
  const _FullscreenIntent();
}

class _QuitIntent extends Intent {
  const _QuitIntent();
}

/// A small reference widget showing active shortcuts — useful in a help overlay.
class ShortcutReferenceCard extends StatelessWidget {
  const ShortcutReferenceCard({super.key});

  static const _shortcuts = [
    ('F1', 'New Sale'),
    ('F2', 'Customer Search'),
    ('F3', 'Product Search'),
    ('F5', 'Checkout'),
    ('F7', 'Reprint Last Receipt'),
    ('F8', 'Cash Drawer'),
    ('F10', 'Today\'s Report'),
    ('F12', 'Toggle Fullscreen'),
    ('Ctrl+P', 'Print'),
    ('Ctrl+Z', 'Remove Last Item'),
    ('Ctrl+Q', 'Quit'),
    ('Esc', 'Cancel / Close'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Keyboard Shortcuts',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._shortcuts.map(
              (s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.4)),
                      ),
                      child: Text(s.$1,
                          style: theme.textTheme.labelSmall?.copyWith(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Text(s.$2, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
