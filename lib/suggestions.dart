import 'package:shared_preferences/shared_preferences.dart';

class Suggestions {
  // Max number of suggestions to show at any time
  int limit = 3;
  // Internal list of all possible suggestions
  List<String> _suggestions = [];

  Suggestions() {
    _load();
  }

  void _load() async {
    final prefs = await SharedPreferences.getInstance();
    _suggestions = prefs.getStringList("suggestions") ?? [];
  }

  void _save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList("suggestions", _suggestions);
  }

  // Get suggestions for a query
  List<String> get(String query) {
    return _suggestions
        .where((String x) => x.toLowerCase().startsWith(query.toLowerCase()))
        .take(limit)
        .toList();
  }

  // Add a new Suggestion
  void add(String newSuggestion) {
    if (!_suggestions.contains(newSuggestion)) {
      _suggestions.add(newSuggestion);
      _save();
    }
  }

  // Clear all suggestions
  void clear() {
    _suggestions.clear();
    _save();
  }
}
