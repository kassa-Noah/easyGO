import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/glass_container.dart';

/// A read-only platform monitor list.
///
/// The four operations screens show the same thing: rows read from the
/// platform, an empty state, and the API's own message when the read fails.
/// Only the row itself differs, so that is the one part each screen supplies.
class AdminMonitorList<T> extends StatefulWidget {
  const AdminMonitorList({
    super.key,
    required this.title,
    required this.load,
    required this.itemBuilder,
    required this.emptyMessage,
  });

  final String title;

  /// Reads the rows. Implemented by the screen so the list stays generic.
  final Future<List<T>> Function() load;

  final Widget Function(BuildContext context, T item) itemBuilder;

  final String emptyMessage;

  @override
  State<AdminMonitorList<T>> createState() => _AdminMonitorListState<T>();
}

class _AdminMonitorListState<T> extends State<AdminMonitorList<T>> {
  List<T> _items = <T>[];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final List<T> items = await widget.load();

      if (!mounted) {
        return;
      }

      setState(() {
        _items = items;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    }
  }

  Widget _panel(BuildContext context, Widget child) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    final List<T> items = _items;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            _panel(
              context,
              Column(
                children: [
                  const Icon(
                    Icons.cloud_off_outlined,
                    color: AppColors.error,
                    size: 34,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  TextButton.icon(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            )
          else if (items.isEmpty)
            _panel(
              context,
              Text(
                widget.emptyMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            ...items.map(
              (T item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassContainer(
                  child: widget.itemBuilder(context, item),
                ),
              ),
            ),
          const SizedBox(height: 12),
          GlassContainer(child: Text(l.adminOperationsReadOnlyNotice)),
        ],
      ),
    );
  }
}
