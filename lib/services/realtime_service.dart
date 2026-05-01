import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../data/network/api_constants.dart';

typedef RealtimeEventCallback = void Function(Map<String, dynamic> payload);

/// Shared socket so cashier VMs (e.g. [PosViewModel], broadcast list) get the same connection.
class RealtimeService {
  RealtimeService._();
  static final RealtimeService _instance = RealtimeService._();
  factory RealtimeService() => _instance;

  static const String _namespace = '/realtime';
  static const String _socketPath = '/socket.io';

  static const String eventCashierTechniciansUpdated = 'cashier.technicians.updated';
  static const String eventTechnicianProfileUpdated = 'technician.profile.updated';
  static const String eventCashierOrdersUpdated = 'cashier.orders.updated';
  static const String eventTechnicianOrdersUpdated = 'technician.assigned-orders.updated';
  static const String eventTechnicianBroadcastCreated = 'technician.broadcast.created';
  static const String eventTechnicianBroadcastClosed = 'technician.broadcast.closed';
  static const String eventCashierBroadcastUpdated = 'cashier.broadcast.updated';
  static const String eventCorporateWalkInOrderUpdated = 'corporate.walk-in-order.updated';
  static const String eventCashierCorporateWalkInApproved = 'cashier.corporate-walk-in.approved';
  static const String eventCashierCorporateWalkInRejected = 'cashier.corporate-walk-in.rejected';
  static const String eventWorkshopPettyCashUpdated = 'workshop.petty-cash.updated';
  static const String eventCashierPettyCashUpdated = 'cashier.petty-cash.updated';

  IO.Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  final Map<String, List<RealtimeEventCallback>> _listeners = {};

  void connect(String token) {
    if (_socket != null) return;

    _socket = IO.io(
      '${ApiConstants.baseUrl}$_namespace',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath(_socketPath)
          .setAuth({'token': token})
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(double.infinity)
          .setReconnectionDelay(3000)
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      print('[Realtime] Connected to socket: $_namespace');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      print('[Realtime] Disconnected from socket');
    });

    _socket!.onConnectError((err) {
      _isConnected = false;
      print('[Realtime] Connection error: $err');
    });

    _socket!.onError((err) {
      print('[Realtime] Socket error: $err');
    });

    _socket!.on(eventCashierTechniciansUpdated, (data) {
      print('[Realtime] cashier.technicians.updated: $data');
      _emit(eventCashierTechniciansUpdated, _toMap(data));
    });

    _socket!.on(eventTechnicianProfileUpdated, (data) {
      print('[Realtime] technician.profile.updated: $data');
      _emit(eventTechnicianProfileUpdated, _toMap(data));
    });

    _socket!.on(eventCashierOrdersUpdated, (data) {
      print('[Realtime] cashier.orders.updated: $data');
      _emit(eventCashierOrdersUpdated, _toMap(data));
    });

    _socket!.on(eventTechnicianOrdersUpdated, (data) {
      print('[Realtime] technician.assigned-orders.updated: $data');
      _emit(eventTechnicianOrdersUpdated, _toMap(data));
    });

    _socket!.on(eventTechnicianBroadcastCreated, (data) {
      print('[Realtime] technician.broadcast.created: $data');
      _emit(eventTechnicianBroadcastCreated, _toMap(data));
    });

    _socket!.on(eventTechnicianBroadcastClosed, (data) {
      print('[Realtime] technician.broadcast.closed: $data');
      _emit(eventTechnicianBroadcastClosed, _toMap(data));
    });

    _socket!.on(eventCashierBroadcastUpdated, (data) {
      print('[Realtime] cashier.broadcast.updated: $data');
      _emit(eventCashierBroadcastUpdated, _toMap(data));
    });

    _socket!.on(eventCorporateWalkInOrderUpdated, (data) {
      print('[Realtime] corporate.walk-in-order.updated: $data');
      _emit(eventCorporateWalkInOrderUpdated, _toMap(data));
    });

    _socket!.on(eventCashierCorporateWalkInApproved, (data) {
      print('[Realtime] cashier.corporate-walk-in.approved: $data');
      _emit(eventCashierCorporateWalkInApproved, _toMap(data));
    });

    _socket!.on(eventCashierCorporateWalkInRejected, (data) {
      print('[Realtime] cashier.corporate-walk-in.rejected: $data');
      _emit(eventCashierCorporateWalkInRejected, _toMap(data));
    });

    _socket!.on(eventWorkshopPettyCashUpdated, (data) {
      print('[Realtime] workshop.petty-cash.updated: $data');
      _emit(eventWorkshopPettyCashUpdated, _toMap(data));
    });

    _socket!.on(eventCashierPettyCashUpdated, (data) {
      print('[Realtime] cashier.petty-cash.updated: $data');
      _emit(eventCashierPettyCashUpdated, _toMap(data));
    });

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    _listeners.clear();
    print('[Realtime] Socket disposed');
  }

  void on(String event, RealtimeEventCallback callback) {
    _listeners.putIfAbsent(event, () => []).add(callback);
  }

  void off(String event, RealtimeEventCallback callback) {
    _listeners[event]?.remove(callback);
  }

  void _emit(String event, Map<String, dynamic> payload) {
    final callbacks = _listeners[event];
    if (callbacks != null) {
      for (final cb in List.of(callbacks)) {
        cb(payload);
      }
    }
  }

  Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }
}
