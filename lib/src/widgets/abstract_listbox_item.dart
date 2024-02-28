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

  final ListItem<T> item;
  final Widget Function(BuildContext context, ListItem<T> item) childTemplate;
  final void Function(ListItem<T> item)? onSelect;
  final bool isDragging;
  final BoxDecoration? customDecoration;

  @override
  State<AbstractListboxItem<T>> createState() => _AbstractListboxItemState<T>();
}

class _AbstractListboxItemState<T> extends State<AbstractListboxItem<T>> {
  bool _isMouseDown = false;

  void _onTapDown(TapDownDetails details) {
    if (widget.item.isSelected) {
      setState(() => _isMouseDown = true);
    } else {
      widget.onSelect!(widget.item);
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (_isMouseDown) {
      widget.onSelect!(widget.item);
    }
    setState(() => _isMouseDown = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: widget.onSelect == null ? null : _onTapDown,
      onTapUp: widget.onSelect == null ? null : _onTapUp,
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
