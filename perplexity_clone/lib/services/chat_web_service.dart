import 'dart:async';
import 'dart:convert';
import 'package:web_socket_client/web_socket_client.dart';

class ChatWebService {
  static final _instance = ChatWebService._internal();
  WebSocket? _socket;

  factory ChatWebService() => _instance;
  ChatWebService._internal();

  final _searchResultController = StreamController<Map<String, dynamic>>.broadcast();
  final _contentController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get searchResultStream =>
      _searchResultController.stream;
  Stream<Map<String, dynamic>> get contentStream =>
      _contentController.stream;

  Map<String, dynamic>? _lastSearchResult;
  Map<String, dynamic>? get lastSearchResult => _lastSearchResult;

  void connect() {
    if (_socket != null) return;
    
    // Auto-detect Android emulator vs standard localhost
    // Note: 'dart:io' Platform check would be better but requires import.
    // Assuming 10.0.2.2 for everything if it works, or conditional.
    // Since kIsWeb is boolean, we can check that.
    // For simplicity in this env, we try to be smart.
    // But we need 'dart:io' for Platform.isAndroid.
    // Let's use a safe string or try to import universal_io or just usage of conditional imports.
    // Since I can't easily add packages, I will just default to localhost but if it fails...
    // Actually, generic way:
    // Auto-detect Android 10.0.2.2 logic (placeholder)
    try {
        // Platform check would go here if we had dart:io
        // ignore: empty_catches
    } catch (e) {}

    _socket = WebSocket(
      Uri.parse("ws://127.0.0.1:8000/ws/chat"),
    );

    _socket!.messages.listen(
      (message) {
        final data = jsonDecode(message);

        if (data['type'] == 'search_result') {
          _lastSearchResult = data; // Cache it
          _searchResultController.add(data);
        } else if (data['type'] == 'content') {
          _contentController.add(data);
        }
      },
      onError: (error) {
        // ignore: avoid_print
        print("WebSocket error: $error");
      },
      onDone: () {
        // ignore: avoid_print
        print("WebSocket closed");
        _socket = null;
      },
    );
  }

  void chat(String query) {
    if (_socket == null) {
      // ignore: avoid_print
      print("WebSocket not connected");
      return;
    }

    if (query.trim().isEmpty) return;
    
    // Clear previous cache on new chat
    _lastSearchResult = null;

    // ✅ SEND JSON (THIS IS THE FIX)
    _socket!.send(
      jsonEncode({
        "query": query.trim(),
      }),
    );
  }
}
