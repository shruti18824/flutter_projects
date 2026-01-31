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

  void connect() {
    if (_socket != null) return;

    _socket = WebSocket(
      Uri.parse("ws://127.0.0.1:8000/ws/chat"),
    );

    _socket!.messages.listen(
      (message) {
        final data = jsonDecode(message);

        if (data['type'] == 'search_result') {
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

    // ✅ SEND JSON (THIS IS THE FIX)
    _socket!.send(
      jsonEncode({
        "query": query.trim(),
      }),
    );
  }
}
