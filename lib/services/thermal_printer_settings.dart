import 'package:shared_preferences/shared_preferences.dart';

/// Saved Wi‑Fi ESC/POS target (e.g. Epson TM‑m30II on LAN port 9100).
abstract final class ThermalPrinterSettings {
  static const prefHost = 'pos_thermal_printer_host';
  static const prefPort = 'pos_thermal_printer_port';

  static const defaultHost = '192.168.8.55';
  static const defaultPort = 9100;

  static Future<({String host, int port})> load() async {
    final p = await SharedPreferences.getInstance();
    var host = p.getString(prefHost)?.trim() ?? '';
    if (host.isEmpty) host = defaultHost;
    var port = p.getInt(prefPort) ?? defaultPort;
    if (port < 1 || port > 65535) port = defaultPort;
    return (host: host, port: port);
  }

  static Future<void> save(String host, int port) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(prefHost, host.trim());
    await p.setInt(prefPort, port);
  }
}
