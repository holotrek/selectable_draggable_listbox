import 'package:selectable_draggable_listbox/src/widgets/abstract_listbox_item.dart';

/// A widget containing a custom Widget for a Listbox item template
class TemplatedListboxItem<T> extends AbstractListboxItem<T> {
  /// A widget containing a custom Widget for a Listbox item template
  const TemplatedListboxItem({
    super.key,
    required super.item,
    required super.childTemplate,
    super.eventManager,
    super.onSelect,
    super.isDragging,
    super.customDecoration,
  });
}
