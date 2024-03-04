import 'package:flutter/material.dart';
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
            GroceryListWidget(),
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
    Widget makeItemTemplate(index, item, onSelect, isDragging) {
      return SimpleListboxItem(
        key: Key('$index'),
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
        final element = _groceryList[oldIndex];
        _groceryList.removeAt(oldIndex);
        _groceryList.insert(newIndex, element);
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
            const Text('Features: Multiselect, Reorder, Drag From'),
            Expanded(
              child: Builder(
                builder: (context) {
                  return Listbox(
                    key: const Key('GroceryList'),
                    items: _groceryList,
                    onSelect: onSelect,
                    onReorder: onReorder,
                    itemTemplate: (context, index, item, onSelect) =>
                        makeItemTemplate(index, item, onSelect, false),
                    dragTemplate: (context, index, item) =>
                        makeItemTemplate(index, item, null, true),
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
    GroceryItem(name: 'Apples'),
    GroceryItem(name: 'Bread'),
  ].forListbox().toList();

  @override
  Widget build(BuildContext context) {
    Widget makeItemTemplate(index, item, label, onSelect) {
      return SimpleListboxItem(
        key: Key('$index'),
        item: item,
        label: label,
        onSelect: onSelect,
      );
    }

    void onSelect(Iterable<ListItem<GroceryItem>> itemsSelected) {
      debugPrint(
          'Selected: ${itemsSelected.map((e) => e.data.name).join(',')}');
      setState(() {
        for (var item in _recentList) {
          item.isSelected = itemsSelected.contains(item);
        }
      });
    }

    void onDrop(Iterable<ListItem<GroceryItem>> itemsDropped, int index) {
      debugPrint(
          'Dropped items ${itemsDropped.map((e) => e.data.name).join(',')} into index $index');

      // It is important to copy the items not just accept them
      // (otherwise they'd have same reference and selected state would cross).
      // Also in this example, we'll avoid adding duplicates.
      final existingNames = _recentList.map((i) => i.data.name);
      final itemsToInsert = itemsDropped
          .where((i) => !existingNames.contains(i.data.name))
          .map((i) => ListItem(GroceryItem(name: i.data.name)))
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
            const Text('Features: Single Select, Drag To'),
            Expanded(
              child: Builder(
                builder: (context) {
                  return Listbox(
                    key: const Key('RecentList'),
                    items: _recentList,
                    onSelect: onSelect,
                    onDrop: onDrop,
                    itemTemplate: (context, index, item, onSelect) =>
                        makeItemTemplate(index, item, item.data.name, onSelect),
                    dropPlaceholderTemplate:
                        (context, index, item, itemsToBeDropped) {
                      var itemsLength = itemsToBeDropped.length;
                      var label = itemsLength > 1
                          ? '$itemsLength new items...'
                          : itemsLength > 0
                              ? itemsToBeDropped.first.data.name
                              : '';
                      return makeItemTemplate(index, item, label, null);
                    },
                    disableMultiSelect: true,
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
