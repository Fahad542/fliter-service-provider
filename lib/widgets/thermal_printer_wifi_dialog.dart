import 'package:flutter/material.dart';

import '../services/thermal_printer_settings.dart';

/// Wi‑Fi ESC/POS printer IP/port (same fields as POS invoice long‑press).
///
/// Persists with [ThermalPrinterSettings] (SharedPreferences). Returns `true`
/// if the user saved valid values. Callers may show a success toast after
/// await (controllers live in dialog [State] so they are never disposed while
/// the route is still updating).
Future<bool> showThermalPrinterWifiDialog(
  BuildContext context, {
  String primaryButtonLabel = 'Save',
}) async {
  final cfg = await ThermalPrinterSettings.load();
  if (!context.mounted) return false;

  final result = await showDialog<bool>(
    context: context,
    builder: (_) => _ThermalPrinterWifiDialog(
      initialHost: cfg.host,
      initialPort: cfg.port,
      primaryButtonLabel: primaryButtonLabel,
    ),
  );

  return result ?? false;
}

class _ThermalPrinterWifiDialog extends StatefulWidget {
  const _ThermalPrinterWifiDialog({
    required this.initialHost,
    required this.initialPort,
    required this.primaryButtonLabel,
  });

  final String initialHost;
  final int initialPort;
  final String primaryButtonLabel;

  @override
  State<_ThermalPrinterWifiDialog> createState() =>
      _ThermalPrinterWifiDialogState();
}

class _ThermalPrinterWifiDialogState extends State<_ThermalPrinterWifiDialog> {
  late final TextEditingController _ipCtrl;
  late final TextEditingController _portCtrl;
  late final VoidCallback _clearErrListener;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ipCtrl = TextEditingController(text: widget.initialHost);
    _portCtrl = TextEditingController(text: '${widget.initialPort}');
    _clearErrListener = () {
      if (_error != null && mounted) setState(() => _error = null);
    };
    _ipCtrl.addListener(_clearErrListener);
    _portCtrl.addListener(_clearErrListener);
  }

  @override
  void dispose() {
    _ipCtrl.removeListener(_clearErrListener);
    _portCtrl.removeListener(_clearErrListener);
    _ipCtrl.dispose();
    _portCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    FocusScope.of(context).unfocus();
    final rawIp = _ipCtrl.text.trim();
    if (!ThermalPrinterSettings.isPlausibleHost(rawIp)) {
      setState(() => _error = 'Enter a valid printer IP or hostname.');
      return;
    }
    final parsedPort = int.tryParse(_portCtrl.text.trim());
    if (parsedPort == null || parsedPort < 1 || parsedPort > 65535) {
      setState(() => _error = 'Enter a valid port (1–65535).');
      return;
    }
    setState(() {
      _error = null;
      _saving = true;
    });
    try {
      await ThermalPrinterSettings.save(rawIp, parsedPort);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not save settings.';
        });
      }
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thermal printer (Wi‑Fi)'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) ...[
              Text(
                _error!,
                style: TextStyle(
                  color: Colors.red.shade800,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _ipCtrl,
              decoration: const InputDecoration(
                labelText: 'Printer IP',
                hintText: 'e.g. 192.168.8.55',
              ),
              enabled: !_saving,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _portCtrl,
              decoration: const InputDecoration(
                labelText: 'Port',
                helperText: '9100 for most Epson network receipt printers',
              ),
              keyboardType: TextInputType.number,
              enabled: !_saving,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _onSave,
          child: _saving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.primaryButtonLabel),
        ),
      ],
    );
  }
}
