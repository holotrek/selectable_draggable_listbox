import 'package:flutter/material.dart';
import 'package:selectable_draggable_listbox/widgets/abstract_listbox_item.dart';

class TemplatedListboxItem<T> extends AbstractListboxItem<T> {
  const TemplatedListboxItem({
    super.key,
    required super.item,
    required super.childTemplate,
    super.onSelect,
    super.isDragging,
    super.customDecoration,
  });

  @override
  State<TemplatedListboxItem<T>> createState() =>
      _TemplatedListboxItemState<T>();
}

class _TemplatedListboxItemState<T> extends State<TemplatedListboxItem<T>> {
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
        child: widget.childTemplate(widget.item),
      ),
    );
  }
}
