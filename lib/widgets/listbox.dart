import 'dart:io';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:selectable_draggable_listbox/models/list_item.dart';
import 'package:selectable_draggable_listbox/widgets/abstract_listbox_item.dart';

class ListBox<T extends Object> extends StatefulWidget {
  ListBox({
    super.key,
    required this.itemTemplate,
    this.dragTemplate,
    required this.results,
    this.onReorder,
    this.onSelect,
  });

  final AbstractListboxItem<T> Function(int index, ListItem<T> item,
      void Function(ListItem<T> item)? onSelect) itemTemplate;
  final AbstractListboxItem<T> Function(int index, ListItem<T> item)?
      dragTemplate;
  final List<ListItem<T>> results;
  final void Function(int oldIndex, int newIndex)? onReorder;
  final void Function(List<ListItem<T>> itemsSelected)? onSelect;
  final controller = ScrollController(keepScrollOffset: true);

  @override
  State<ListBox<T>> createState() => _ListBoxState<T>();
}

class _ListBoxState<T extends Object> extends State<ListBox<T>> {
  int? _lastIndexSelected;
  bool _isCtrlOrCommandDown = false;
  bool _isShiftDown = false;
  late FocusNode _node;
  bool _focused = false;
  late FocusAttachment _nodeAttachment;

  @override
  void initState() {
    super.initState();
    _node = FocusNode(debugLabel: 'Listbox');
    _node.addListener(_handleFocusChange);
    _nodeAttachment = _node.attach(context, onKeyEvent: _handleKeyPress);
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
        'Focus node ${node.debugLabel} got key event: ${event.logicalKey}');
    if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
        event.logicalKey == LogicalKeyboardKey.shiftRight) {
      debugPrint('Shift toggled.');
      setState(() {
        _isShiftDown = !isKeyUp;
      });
      return KeyEventResult.handled;
    } else if (Platform.isMacOS) {
      if (event.logicalKey == LogicalKeyboardKey.metaLeft ||
          event.logicalKey == LogicalKeyboardKey.metaRight) {
        debugPrint('Command toggled.');
        setState(() {
          _isCtrlOrCommandDown = !isKeyUp;
        });
        return KeyEventResult.handled;
      }
    } else {
      if (event.logicalKey == LogicalKeyboardKey.controlLeft ||
          event.logicalKey == LogicalKeyboardKey.controlRight) {
        debugPrint('Control toggled.');
        setState(() {
          _isCtrlOrCommandDown = !isKeyUp;
        });
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _node.removeListener(_handleFocusChange);
    // The attachment will automatically be detached in dispose().
    _node.dispose();
    super.dispose();
  }

  void onSelect(ListItem<T> item) {
    if (widget.onSelect == null) {
      return;
    }

    final existingItemsSelected =
        widget.results.where((e) => e.isSelected).toList();
    List<ListItem<T>> itemsSelected =
        _isCtrlOrCommandDown ? existingItemsSelected : [];

    int itemIndex = widget.results.indexOf(item);
    bool shiftSelectUsed = false;
    if (_isShiftDown) {
      if (_lastIndexSelected != null &&
          widget.results[_lastIndexSelected!].isSelected &&
          itemIndex != _lastIndexSelected) {
        int firstIndex = math.min(itemIndex, _lastIndexSelected!);
        int lastIndex = math.max(itemIndex, _lastIndexSelected!);
        itemsSelected.addAll(widget.results.slice(firstIndex, lastIndex + 1));
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

    return GestureDetector(
      onTap: () {
        if (!_focused) {
          _node.requestFocus();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: colors.surface),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Scrollbar(
            controller: widget.controller,
            child: Builder(
              builder: (context) {
                final selectedItems =
                    widget.results.where((i) => i.isSelected).toList();
                itemBuilder(BuildContext context, int idx) =>
                    widget.itemTemplate(idx, widget.results[idx], onSelect);

                Widget listView;
                if (widget.onReorder == null) {
                  listView = ListView.builder(
                    controller: widget.controller,
                    itemCount: widget.results.length,
                    itemBuilder: itemBuilder,
                  );
                } else {
                  listView = ReorderableListView.builder(
                    onReorder: widget.onReorder!,
                    scrollController: widget.controller,
                    itemCount: widget.results.length,
                    itemBuilder: itemBuilder,
                  );
                }

                if (widget.dragTemplate == null) {
                  return listView;
                } else {
                  dragItemBuilder(BuildContext context, int idx) =>
                      widget.dragTemplate!(idx, selectedItems[idx]);

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
