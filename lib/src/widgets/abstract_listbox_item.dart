import 'package:flutter/material.dart';
import 'package:selectable_draggable_listbox/selectable_draggable_listbox.dart';

abstract class AbstractListboxItem<T> extends StatefulWidget {
  const AbstractListboxItem({
    super.key,
    required this.item,
    required this.childTemplate,
    this.eventManager,
    this.onSelect,
    this.isDragging = false,
    this.customDecoration,
  });

  /// The data item bound to this Lisbox item
  final ListItem<T> item;

  /// A tracker of listbox events that allows this widget to listen to them
  final ListboxEventManager? eventManager;

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

class _AbstractListboxItemState<T> extends State<AbstractListboxItem<T>>
    with ListboxListener {
  bool _isMouseUp = false;
  bool _isMouseDown = false;
  bool _handledByMouseDown = false;

  void _handleTapDownOrDragStart() {
    if (widget.onSelect == null) {
      return;
    }

    // Only select item on down if it is not already selected, so that if you
    // click down to drag on a previously selected item, it won't unselect it.
    // Also, since Tap and Drag down could both be fired, avoid doing it twice,
    // so check if _isMouseDown is already set.
    if (!_isMouseDown && !widget.item.isSelected) {
      widget.onSelect!(widget.item);
      setState(() => _handledByMouseDown = true);
    }
    setState(() {
      _isMouseUp = false;
      _isMouseDown = true;
    });
  }

  void _handleTapUpOrDragStop() {
    if (widget.onSelect == null) {
      return;
    }

    // If the mouse up is done on an item already selected (and thus down
    // ignored it), then unselect it
    if (!_isMouseUp && widget.item.isSelected && !_handledByMouseDown) {
      widget.onSelect!(widget.item);
    }
    setState(() {
      _isMouseUp = true;
      _isMouseDown = false;
      _handledByMouseDown = false;
    });
  }

  void _onPointerDown(PointerDownEvent details) {
    _handleTapDownOrDragStart();
  }

  void _onPointerUp(PointerUpEvent details) {
    _handleTapUpOrDragStop();
  }

  @override
  void onListDragEnd() {
    super.onListDragEnd();
    setState(() {
      _isMouseUp = true;
      _isMouseDown = false;
      _handledByMouseDown = false;
    });
  }

  @override
  void initState() {
    super.initState();
    widget.eventManager?.addListener(this);
  }

  @override
  void dispose() {
    widget.eventManager?.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Listener(
      onPointerDown: widget.onSelect == null ? null : _onPointerDown,
      onPointerUp: widget.onSelect == null ? null : _onPointerUp,
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
