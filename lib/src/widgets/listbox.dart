import 'dart:io';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:selectable_draggable_listbox/src/models/list_item.dart';

class Listbox<T> extends StatefulWidget {
  /// Builds a listbox that is a reorderable, (multi)selectable, listview of
  /// widgets defined by the itemTemplate.
  Listbox({
    super.key,
    required this.itemTemplate,
    this.dragTemplate,
    required this.items,
    this.shrinkWrap = false,
    this.disableMultiSelect = false,
    this.onReorder,
    this.onSelect,
    this.enableDebug = false,
  });

  /// Builds the widget that should show in the list for each item.
  final Widget Function(BuildContext context, int index, ListItem<T> item,
      void Function(ListItem<T> item)? onSelect) itemTemplate;

  /// Builds the widget that should show when dragging the item from the list.
  /// Set to null to disable dragging from this Listbox.
  final Widget Function(BuildContext context, int index, ListItem<T> item)?
      dragTemplate;

  /// Items to bind to the Listbox.
  final List<ListItem<T>> items;

  /// Whether to shrinkWrap the scroll view. See this documentation for more
  /// info: https://api.flutter.dev/flutter/widgets/ScrollView/shrinkWrap.html
  final bool shrinkWrap;

  /// Whether to allow multiple selections in a series (using Shift) or
  /// individually selected (using Ctrl or Command on MacOS).
  final bool disableMultiSelect;

  /// A callback used by the Listbox to report that a list item has been dragged
  /// to a new location in the list.
  final void Function(int oldIndex, int newIndex)? onReorder;

  /// A callback used by the Listbox to report that one or more list items have
  /// been selected. Set to null to disable selections.
  final void Function(List<ListItem<T>> itemsSelected)? onSelect;

  /// Whether to show debug info about this widget
  final bool enableDebug;

  final controller = ScrollController(keepScrollOffset: true);

  @override
  State<Listbox<T>> createState() => _ListboxState<T>();
}

class _ListboxState<T> extends State<Listbox<T>> {
  int? _lastIndexSelected;
  bool _isCtrlOrCommandDown = false;
  bool _isShiftDown = false;
  late FocusNode _node;
  bool _focused = false;
  late FocusAttachment _nodeAttachment;

  @override
  void initState() {
    super.initState();
    _node = FocusNode(debugLabel: 'Listbox (key:${widget.key})');
    _node.addListener(_handleFocusChange);
    _nodeAttachment = _node.attach(context, onKeyEvent: _handleKeyPress);
  }

  @override
  void dispose() {
    _node.removeListener(_handleFocusChange);
    // The attachment will automatically be detached in dispose().
    _node.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_node.hasFocus != _focused) {
      setState(() {
        _focused = _node.hasFocus;
      });
    }
  }

  KeyEventResult _handleKeyPress(FocusNode node, KeyEvent event) {
    bool isKeyUp = event is KeyUpEvent;
    debugPrint(
        '[selectable_draggable_listbox] Focus node ${node.debugLabel} got key ${isKeyUp ? 'up' : 'down'} event: ${event.logicalKey}');
    if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
        event.logicalKey == LogicalKeyboardKey.shiftRight) {
      setState(() {
        _isShiftDown = !isKeyUp;
      });
      return KeyEventResult.handled;
    } else if (Platform.isMacOS) {
      if (event.logicalKey == LogicalKeyboardKey.metaLeft ||
          event.logicalKey == LogicalKeyboardKey.metaRight) {
        setState(() {
          _isCtrlOrCommandDown = !isKeyUp;
        });
        return KeyEventResult.handled;
      }
    } else {
      if (event.logicalKey == LogicalKeyboardKey.controlLeft ||
          event.logicalKey == LogicalKeyboardKey.controlRight) {
        setState(() {
          _isCtrlOrCommandDown = !isKeyUp;
        });
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _listClicked() {
    if (!_focused) {
      debugPrint(
          '[selectable_draggable_listbox] Listbox (key:${widget.key}) requesting focus.');
      _node.requestFocus();
    }
  }

  void _onSelect(ListItem<T> item) {
    _listClicked();

    if (widget.onSelect == null) {
      return;
    }

    final existingItemsSelected =
        widget.items.where((e) => e.isSelected).toList();
    List<ListItem<T>> itemsSelected =
        _isCtrlOrCommandDown && !widget.disableMultiSelect
            ? existingItemsSelected
            : [];

    int itemIndex = widget.items.indexOf(item);
    bool shiftSelectUsed = false;
    if (_isShiftDown && !widget.disableMultiSelect) {
      if (_lastIndexSelected != null &&
          widget.items[_lastIndexSelected!].isSelected &&
          itemIndex != _lastIndexSelected) {
        int firstIndex = math.min(itemIndex, _lastIndexSelected!);
        int lastIndex = math.max(itemIndex, _lastIndexSelected!);
        itemsSelected.addAll(widget.items.slice(firstIndex, lastIndex + 1));
        shiftSelectUsed = true;
      }
    }

    if (!shiftSelectUsed) {
      if (!item.isSelected ||
          (!_isCtrlOrCommandDown && existingItemsSelected.length > 1)) {
        itemsSelected.add(item);
        _lastIndexSelected = itemIndex;
      } else {
        itemsSelected.remove(item);
      }
    }

    widget.onSelect!(itemsSelected);
  }

  @override
  Widget build(BuildContext context) {
    _nodeAttachment.reparent();
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: colors.surface),
        ],
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (_) => _listClicked(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Scrollbar(
            controller: widget.controller,
            child: Builder(
              builder: (context) {
                final selectedItems =
                    widget.items.where((i) => i.isSelected).toList();
                itemBuilder(BuildContext context, int idx) => widget
                    .itemTemplate(context, idx, widget.items[idx], _onSelect);

                Widget listView;
                if (widget.onReorder == null) {
                  listView = ListView.builder(
                    controller: widget.controller,
                    itemCount: widget.items.length,
                    itemBuilder: itemBuilder,
                    shrinkWrap: widget.shrinkWrap,
                  );
                } else {
                  listView = ReorderableListView.builder(
                    onReorder: (int oldIndex, int newIndex) {
                      if (newIndex > oldIndex) {
                        /// Reorderable listview incorrectly adds 1 to newindex
                        /// when moving such that index increases. See
                        /// https://github.com/flutter/flutter/issues/24786
                        /// for more info.
                        newIndex--;
                      }
                      widget.onReorder!(oldIndex, newIndex);
                    },
                    scrollController: widget.controller,
                    itemCount: widget.items.length,
                    itemBuilder: itemBuilder,
                    shrinkWrap: widget.shrinkWrap,
                  );
                }

                if (widget.dragTemplate == null) {
                  return listView;
                } else {
                  dragItemBuilder(BuildContext context, int idx) =>
                      widget.dragTemplate!(context, idx, selectedItems[idx]);

                  return Draggable<Iterable<T>>(
                    data: selectedItems.map((i) => i.data).toList(),
                    dragAnchorStrategy: pointerDragAnchorStrategy,
                    feedback: SizedBox(
                      width: 350,
                      height: selectedItems.length * 50,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: selectedItems.length,
                        itemBuilder: dragItemBuilder,
                      ),
                    ),
                    child: listView,
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
