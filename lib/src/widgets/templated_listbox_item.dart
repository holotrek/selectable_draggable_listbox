import 'package:selectable_draggable_listbox/src/widgets/abstract_listbox_item.dart';

class TemplatedListboxItem<T> extends AbstractListboxItem<T> {
  const TemplatedListboxItem({
    super.key,
    required super.item,
    required super.childTemplate,
    super.onSelect,
    super.isDragging,
    super.customDecoration,
  });
}
