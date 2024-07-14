import 'package:flutter/foundation.dart';
import 'package:selectable_draggable_listbox/selectable_draggable_listbox.dart';

/// Manages the listeners that the Listbox will publish events to
class ListboxEventManager {
  final List<ListboxListener> _listeners = [];

  void addListener(ListboxListener listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  void removeListener(ListboxListener listener) {
    _listeners.remove(listener);
  }

  void removeAll() {
    _listeners.clear();
  }

  void triggerListDragStart({bool enableDebug = true}) {
    if (enableDebug) {
      debugPrint('[selectable_draggable_listbox] List drag started');
    }

    for (var l in _listeners) {
      l.onListDragStart();
    }
  }

  void triggerListDragEnd({bool enableDebug = true}) {
    if (enableDebug) {
      debugPrint('[selectable_draggable_listbox] List drag ended');
    }

    for (var l in _listeners) {
      l.onListDragEnd();
    }
  }
}
