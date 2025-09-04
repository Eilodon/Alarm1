import 'package:flutter/foundation.dart';

class NoteProvider extends ChangeNotifier {
  String _draft = '';

  String get draft => _draft;

  void setDraft(String text) {
    _draft = text;
    notifyListeners();
  }

  void clear() {
    _draft = '';
    notifyListeners();
  }
}
