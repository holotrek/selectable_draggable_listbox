import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:selectable_draggable_listbox/selectable_draggable_listbox.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Selectable Draggable Listbox Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Selectable Draggable Listbox Demo'),
    );
  }
}

class GroceryItem {
  final String name;

  GroceryItem({
    required this.name,
  });
}

class RecentGroceryItem extends GroceryItem {
  DateTime lastBought;

  String get lastBoughtShortDtTm =>
      DateFormat('MM/dd/yyyy kk:mm').format(lastBought);

  RecentGroceryItem({
    required super.name,
    required this.lastBought,
  });
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // See this widget for: Multi-select, Reorder, and Drag From
            GroceryListWidget(),

            // See this widget for: Single-select, Customized Template, and Drag To
            RecentListWidget(),
          ],
        ),
      ),
    );
  }
}

class GroceryListWidget extends StatefulWidget {
  const GroceryListWidget({
    super.key,
  });

  @override
  State<GroceryListWidget> createState() => _GroceryListWidgetState();
}

class _GroceryListWidgetState extends State<GroceryListWidget> {
  final _groceryList = [
    GroceryItem(name: 'Apples'),
    GroceryItem(name: 'Bananas'),
    GroceryItem(name: 'Milk'),
    GroceryItem(name: 'Cheese'),
    GroceryItem(name: 'Bread'),
  ].forListbox().toList();

  @override
  Widget build(BuildContext context) {
    /// Make a simple listbox item
    /// This demonstrates using the index to show a number prefix
    /// Slightly different for the "drag template" that follows your mouse pointer - removes the number prefix
    SimpleListboxItem<GroceryItem> makeItemTemplate(
      int index,
      ListboxEventManager eventManager,
      ListItem<GroceryItem> item,
      void Function(ListItem<GroceryItem>)? onSelect,
      bool isDragging,
    ) {
      return SimpleListboxItem(
        key: Key('$index'),
        eventManager: eventManager,
        item: item,
        label: isDragging ? item.data.name : '${index + 1}. ${item.data.name}',
        onSelect: onSelect,
        isDragging: isDragging,
      );
    }

    void onSelect(Iterable<ListItem<GroceryItem>> itemsSelected) {
      debugPrint(
          'Selected: ${itemsSelected.map((e) => e.data.name).join(',')}');
      setState(() {
        for (var item in _groceryList) {
          item.isSelected = itemsSelected.contains(item);
        }
      });
    }

    void onReorder(int oldIndex, int newIndex) {
      debugPrint('Moving item from $oldIndex to $newIndex');
      setState(() {
        // Note: this is an extension provided by the package
        _groceryList.move(oldIndex, newIndex);
      });
    }

    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'Grocery List',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const Text('Features: Multi-select, Reorder, Drag From'),
            Expanded(
              child: Builder(
                builder: (context) {
                  return Listbox(
                    // Key is only needed if you want to identify which list you're interacting with in debug:
                    key: const Key('GroceryList'),
                    items: _groceryList,
                    onSelect: onSelect,
                    onReorder: onReorder,
                    itemTemplate:
                        (context, eventManager, index, item, onSelect) =>
                            makeItemTemplate(
                                index, eventManager, item, onSelect, false),
                    dragTemplate: (context, eventManager, index, item) =>
                        makeItemTemplate(index, eventManager, item, null, true),
                    // Show info in console about how the list is being interacted with:
                    enableDebug: true,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecentListWidget extends StatefulWidget {
  const RecentListWidget({
    super.key,
  });

  @override
  State<RecentListWidget> createState() => _RecentListWidgetState();
}

class _RecentListWidgetState extends State<RecentListWidget> {
  final _recentList = [
    RecentGroceryItem(
      name: 'Apples',
      lastBought: DateTime(2024, 3, 3, 13, 22, 33),
    ),
    RecentGroceryItem(
      name: 'Bread',
      lastBought: DateTime(2024, 3, 4, 10, 14, 12),
    )
  ].forListbox().toList();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    /// Make a more complex listbox item
    /// This demonstrates using the childTemplate to show a row with a badge
    /// indicating the date the item was dragged to this list
    TemplatedListboxItem<RecentGroceryItem> makeItemTemplate(
      int index,
      ListboxEventManager eventManager,
      ListItem<RecentGroceryItem> item,
      String label,
      void Function(ListItem<RecentGroceryItem>)? onSelect,
      bool isDragPlaceholder,
    ) {
      return TemplatedListboxItem(
        key: Key('$index'),
        item: item,
        childTemplate: (context, item) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label),
                if (!isDragPlaceholder)
                  Badge(
                    label: Text(item.data.lastBoughtShortDtTm),
                  ),
              ],
            ),
          );
        },
        eventManager: eventManager,
        onSelect: onSelect,
        customDecoration: isDragPlaceholder
            ? BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: const BorderRadius.all(
                  Radius.circular(5),
                ),
              )
            : null,
      );
    }

    void onSelect(Iterable<ListItem<RecentGroceryItem>> itemsSelected) {
      debugPrint(
          'Selected: ${itemsSelected.map((e) => e.data.name).join(',')}');
      setState(() {
        for (var item in _recentList) {
          item.isSelected = itemsSelected.contains(item);
        }
      });
    }

    void onDrop(Iterable<ListItem<RecentGroceryItem>> itemsDropped, int index) {
      debugPrint(
          'Dropped items ${itemsDropped.map((e) => e.data.name).join(',')} into index $index');

      // Avoid adding duplicates
      final existingNames = _recentList.map((i) => i.data.name);

      // We can add these items to the list directly, because our transform made
      // copies of the items. When not using dragDropTransform it's a good idea
      // to clone the items here before inserting them into the new list.
      final itemsToInsert = itemsDropped
          .where((i) => !existingNames.contains(i.data.name))
          .toList();
      _recentList.insertAll(index, itemsToInsert);
    }

    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'Recently Bought',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const Text('Features: Single-select, Customized Template, Drag To'),
            Expanded(
              child: Builder(
                builder: (context) {
                  return Listbox(
                    // Key is only needed if you want to identify which list you're interacting with in debug:
                    key: const Key('RecentList'),
                    items: _recentList,
                    onSelect: onSelect,
                    onDrop: onDrop,
                    dragDropTransform: (input) {
                      if (input is GroceryItem || input is RecentGroceryItem) {
                        return RecentGroceryItem(
                            name: input.name, lastBought: DateTime.now());
                      } else {
                        throw Exception(
                            'Cannot accept items of type ${input.runtimeType}');
                      }
                    },
                    itemTemplate:
                        (context, eventManager, index, item, onSelect) =>
                            makeItemTemplate(index, eventManager, item,
                                item.data.name, onSelect, false),
                    dropPlaceholderTemplate:
                        (context, eventManager, index, item, itemsToBeDropped) {
                      var itemsLength = itemsToBeDropped.length;

                      // Here we're going to adjust the label that shows in the new list's placeholder,
                      // depending on whether we are dragging 1 item (just show name) or more (count of new items)
                      var label = itemsLength > 1
                          ? '$itemsLength new items...'
                          : itemsLength > 0
                              ? itemsToBeDropped.first.data.name
                              : '';
                      return makeItemTemplate(
                          index, eventManager, item, label, null, true);
                    },
                    // Can just turn off multiselect if not needed:
                    disableMultiSelect: true,
                    // Show info in console about how the list is being interacted with:
                    enableDebug: true,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
