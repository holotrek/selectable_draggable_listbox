import 'dart:io';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:selectable_draggable_listbox/selectable_draggable_listbox.dart';

/// Builds a listbox that is a reorderable, (multi)selectable, listview of
/// widgets defined by the itemTemplate.
class Listbox<T, TItem extends AbstractListboxItem<T>> extends StatefulWidget {
  /// Builds a listbox that is a reorderable, (multi)selectable, listview of
  /// widgets defined by the itemTemplate.
  const Listbox({
    super.key,
    required this.itemTemplate,
    this.dragTemplate,
    this.dropPlaceholderTemplate,
    required this.items,
    this.shrinkWrap = false,
    this.disableMultiSelect = false,
    this.onReorder,
    this.onSelect,
    this.onDrop,
    this.dragDropTransform,
    this.enableDebug = false,
  });

  /// Builds the widget that should show in the list for each item.
  final TItem Function(BuildContext context, int index, ListItem<T> item,
      void Function(ListItem<T> item)? onSelect) itemTemplate;

  /// Builds the widget that should show when dragging the item from the list.
  /// Set to null to disable dragging from this Listbox.
  final TItem Function(BuildContext context, int index, ListItem<T> item)?
      dragTemplate;

  /// Builds the widget that should show as a placeholder when item(s) are being
  /// dragged to this Listbox. If used, must also provide [onDrop]. Set to null
  /// to disable dragging to this list.
  final TItem Function(BuildContext context, int index, ListItem<T> item,
      Iterable<ListItem<T>> itemsToBeDropped)? dropPlaceholderTemplate;

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
  final void Function(Iterable<ListItem<T>> itemsSelected)? onSelect;

  /// A callback used by the Listbox to report that one or more list items have
  /// been dropped into this list. If used, must also provide
  /// [dropPlaceholderTemplate]. Set to null to disable dragging to this list.
  final void Function(Iterable<ListItem<T>> itemsDropped, int index)? onDrop;

  /// Defines how to transform a different dragged type into the type to be
  /// dropped into this list. Defaults to returning the exact same item. If
  /// returning the same reference, remember that you might need to clone it in
  /// [onDrop].
  final T Function(dynamic input)? dragDropTransform;

  /// Whether to show debug info about this widget
  final bool enableDebug;

  @override
  State<Listbox<T, TItem>> createState() => _ListboxState<T, TItem>();
}

class _ListboxState<T, TItem extends AbstractListboxItem<T>>
    extends State<Listbox<T, TItem>> {
  int? _lastIndexSelected;
  bool _isCtrlOrCommandDown = false;
  bool _isShiftDown = false;
  late FocusNode _node;
  bool _focused = false;
  late FocusAttachment _nodeAttachment;
  Iterable<ListItem<T>> _itemsToBeDropped = [];
  bool _isDraggedOver = false;
  int _dropIndex = -1;

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
    } else if (kIsWeb || Platform.isMacOS) {
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
      final keysPressed = ServicesBinding.instance.keyboard.logicalKeysPressed;

      final isShiftDown = keysPressed.intersection({
        LogicalKeyboardKey.shiftLeft,
        LogicalKeyboardKey.shiftRight,
      }).isNotEmpty;

      Set<LogicalKeyboardKey> ctrlOrCommandToCheck = {
        LogicalKeyboardKey.metaLeft,
        LogicalKeyboardKey.metaRight,
        LogicalKeyboardKey.controlLeft,
        LogicalKeyboardKey.controlRight,
      };
      if (!kIsWeb) {
        if (Platform.isMacOS) {
          ctrlOrCommandToCheck = {
            LogicalKeyboardKey.metaLeft,
            LogicalKeyboardKey.metaRight,
          };
        } else {
          ctrlOrCommandToCheck = {
            LogicalKeyboardKey.controlLeft,
            LogicalKeyboardKey.controlRight,
          };
        }
      }

      final isCtrlOrCommandDown =
          keysPressed.intersection(ctrlOrCommandToCheck).isNotEmpty;

      debugPrint(
          '[selectable_draggable_listbox] Shift is currently ${isShiftDown ? 'down' : 'up'}.');
      debugPrint(
          '[selectable_draggable_listbox] Ctrl/Cmd is currently ${isCtrlOrCommandDown ? 'down' : 'up'}.');
      setState(() {
        _isShiftDown = isShiftDown;
        _isCtrlOrCommandDown = isCtrlOrCommandDown;
      });
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
    final adjustedItems = widget.items.toList();
    final colors = Theme.of(context).colorScheme;
    final originalResultCount = adjustedItems.length;
    final transformer =
        widget.dragDropTransform ?? (dynamic input) => input as T;

    listItemTransformer(ListItem<dynamic> input) =>
        ListItem(transformer(input.data));

    if (_isDraggedOver && _dropIndex > -1 && _itemsToBeDropped.isNotEmpty) {
      adjustedItems.insert(
          _dropIndex, ListItem<T>.asPlaceholder(_itemsToBeDropped.first));
    }

    Offset localOffset(Offset offset) {
      var box = context.findRenderObject() as RenderBox;
      var listPosition = box.localToGlobal(Offset.zero);
      return offset - listPosition;
    }

    int getDropIndex(Offset offset, int listLength) {
      return math.min(math.max(0, (offset.dy / 30).floor()), listLength);
    }

    var listboxBuilder = Container(
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: colors.surface,
          ),
        ],
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (_) => _listClicked(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Builder(
            builder: (context) {
              final selectedItems =
                  adjustedItems.where((i) => i.isSelected).toList();
              itemBuilder(BuildContext context, int idx) {
                if (widget.dropPlaceholderTemplate != null &&
                    adjustedItems[idx].isPlaceholder) {
                  return widget.dropPlaceholderTemplate!(
                      context, idx, adjustedItems[idx], _itemsToBeDropped);
                } else {
                  return widget.itemTemplate(
                      context, idx, adjustedItems[idx], _onSelect);
                }
              }

              Widget listView;
              if (widget.onReorder == null) {
                listView = ListView.builder(
                  itemCount: adjustedItems.length,
                  itemBuilder: itemBuilder,
                  shrinkWrap: widget.shrinkWrap,
                );
              } else {
                listView = ReorderableListView.builder(
                  onReorder: (int oldIndex, int newIndex) {
                    if (newIndex > oldIndex) {
                      // Reorderable listview incorrectly adds 1 to newindex
                      // when moving such that index increases. See
                      // https://github.com/flutter/flutter/issues/24786
                      // for more info.
                      newIndex--;
                    }
                    widget.onReorder!(oldIndex, newIndex);
                  },
                  itemCount: adjustedItems.length,
                  itemBuilder: itemBuilder,
                  shrinkWrap: widget.shrinkWrap,
                );
              }

              if (widget.dragTemplate == null) {
                return listView;
              } else {
                dragItemBuilder(BuildContext context, int idx) =>
                    widget.dragTemplate!(context, idx, selectedItems[idx]);

                return Draggable<Iterable<ListItem<T>>>(
                  hitTestBehavior: HitTestBehavior.translucent,
                  data: selectedItems,
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
    );

    if (widget.onDrop == null || widget.dropPlaceholderTemplate == null) {
      return listboxBuilder;
    } else {
      return DragTarget<Iterable<ListItem<dynamic>>>(
        builder: (context, candidateData, rejectedData) => listboxBuilder,
        onWillAcceptWithDetails: (details) => details.data.isNotEmpty == true,
        onAcceptWithDetails: (details) {
          var offset = localOffset(details.offset);
          var dropIndex = getDropIndex(offset, originalResultCount);
          debugPrint('Dropping items into ${widget.key} at index $_dropIndex');
          var droppedItems = details.data.toList();
          for (var element in droppedItems) {
            element.isSelected = false;
          }
          var transformedItems = droppedItems.map(listItemTransformer);
          widget.onDrop!(transformedItems, dropIndex);
          setState(() {
            _isDraggedOver = false;
            _dropIndex = -1;
          });
        },
        onMove: (details) {
          var offset = localOffset(details.offset);
          var index = getDropIndex(offset, originalResultCount);
          if (index != _dropIndex) {
            debugPrint(
                'Ready to drop items into ${widget.key} at index $index');
          }
          setState(() {
            _itemsToBeDropped = details.data.map(listItemTransformer).toList();
            _isDraggedOver = true;
            _dropIndex = index;
          });
        },
        onLeave: (data) {
          debugPrint('No longer ready to drop items.');
          setState(() {
            _isDraggedOver = false;
            _dropIndex = -1;
          });
        },
      );
    }
  }
}
