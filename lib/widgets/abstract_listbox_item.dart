import 'package:flutter/widgets.dart';
import 'package:selectable_draggable_listbox/models/list_item.dart';

abstract class AbstractListboxItem<T> extends StatefulWidget {
  const AbstractListboxItem({
    super.key,
    required this.item,
    required this.childTemplate,
    this.onSelect,
    this.isDragging = false,
    this.customDecoration,
  });

  final ListItem<T> item;
  final Widget Function(ListItem<T> item) childTemplate;
  final void Function(ListItem<T> item)? onSelect;
  final bool isDragging;
  final BoxDecoration? customDecoration;
}
