import 'package:flutter/material.dart';
import 'package:selectable_draggable_listbox/src/models/list_item.dart';

abstract class AbstractListboxItem<T> extends StatefulWidget {
  const AbstractListboxItem({
    super.key,
    required this.item,
    required this.childTemplate,
    this.onSelect,
    this.isDragging = false,
    this.customDecoration,
  });

  /// The data item bound to this Lisbox item
  final ListItem<T> item;

  /// Builds the widget to display for this Listbox item
  final Widget Function(BuildContext context, ListItem<T> item) childTemplate;

  /// A callback that indicates that the item has been selected (or deselected)
  final void Function(ListItem<T> item)? onSelect;

  /// Indicates whether the item is currently being dragged
  final bool isDragging;

  /// Override the decoration used to indicate that the item is selected/dragged
  final BoxDecoration? customDecoration;

  @override
  State<AbstractListboxItem<T>> createState() => _AbstractListboxItemState<T>();
}

class _AbstractListboxItemState<T> extends State<AbstractListboxItem<T>> {
  bool _isMouseDown = false;

  void _onTapDown(TapDownDetails details) {
    debugPrint('Mouse down');
    if (widget.item.isSelected) {
      setState(() => _isMouseDown = true);
    } else {
      widget.onSelect!(widget.item);
    }
  }

  void _onTapUp(TapUpDetails details) {
    debugPrint('Mouse up');
    if (_isMouseDown) {
      widget.onSelect!(widget.item);
    }
    setState(() => _isMouseDown = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: widget.onSelect == null ? null : _onTapDown,
      onTapUp: widget.onSelect == null ? null : _onTapUp,
      // onHorizontalDragStart: (_) => debugPrint('Drag Start'),
      // onVerticalDragStart: (_) => debugPrint('Drag Start'),
      // onHorizontalDragDown: (_) => debugPrint('Drag Down'),
      // onVerticalDragDown: (_) => debugPrint('Drag Down'),
      // onHorizontalDragUpdate: (_) => debugPrint('Dragging'),
      // onVerticalDragUpdate: (_) => debugPrint('Dragging'),
      child: Container(
        decoration: widget.customDecoration ??
            BoxDecoration(
              color: widget.isDragging
                  ? colorScheme.primaryContainer
                  : widget.item.isSelected
                      ? colorScheme.secondaryContainer
                      : null,
              border: Border.all(
                color: colorScheme.primary,
                style: widget.item.isSelected || widget.isDragging
                    ? BorderStyle.solid
                    : BorderStyle.none,
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(5),
              ),
            ),
        margin: const EdgeInsets.all(2),
        child: widget.childTemplate(context, widget.item),
      ),
    );
  }
}
