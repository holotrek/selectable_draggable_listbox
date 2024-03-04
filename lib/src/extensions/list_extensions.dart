import 'package:selectable_draggable_listbox/selectable_draggable_listbox.dart';

extension MoveElement on List {
  /// Moves an element in the list at "from" index to a new "to" index
  void move(int from, int to) {
    RangeError.checkValidIndex(from, this, "from", length);
    RangeError.checkValidIndex(to, this, "to", length);
    var element = this[from];
    if (from < to) {
      setRange(from, to, this, from + 1);
    } else {
      setRange(to + 1, from + 1, this, to);
    }
    this[to] = element;
  }
}

extension MapToListboxItems<T> on Iterable<T> {
  /// Transforms the collection to one that the Listbox can use
  Iterable<ListItem<T>> forListbox() {
    return map((e) => ListItem(e));
  }
}
