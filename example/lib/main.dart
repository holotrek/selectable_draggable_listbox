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
  final _groceryList = [
    GroceryItem(name: 'Apples'),
    GroceryItem(name: 'Bananas'),
    GroceryItem(name: 'Milk'),
    GroceryItem(name: 'Cheese'),
    GroceryItem(name: 'Bread'),
  ].forListbox().toList();

  final List<ListItem<GroceryItem>> _recentList = [];

  Listbox<GroceryItem> _makeGroceryListbox(
      List<ListItem<GroceryItem>> list, String name) {
    Widget makeItemTemplate(context, index, item, onSelect, isDragging) {
      return SimpleListboxItem(
        key: Key('$index'),
        item: item,
        label: isDragging ? item.data.name : '${index + 1}. ${item.data.name}',
        onSelect: onSelect,
        isDragging: isDragging,
      );
    }

    return Listbox(
      key: Key(name),
      items: list,
      onSelect: (itemsSelected) {
        debugPrint(
            'Selected: ${itemsSelected.map((e) => e.data.name).join(',')}');
        setState(() {
          for (var item in list) {
            item.isSelected = itemsSelected.contains(item);
          }
        });
      },
      onReorder: (oldIndex, newIndex) {
        debugPrint('Moving item from $oldIndex to $newIndex');
        setState(() {
          final element = list[oldIndex];
          list.removeAt(oldIndex);
          list.insert(newIndex, element);
        });
      },
      itemTemplate: (context, index, item, onSelect) =>
          makeItemTemplate(context, index, item, onSelect, false),
      dragTemplate: (context, index, item) =>
          makeItemTemplate(context, index, item, null, true),
      enableDebug: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Grocery List',
                    ),
                    Expanded(
                      child: _makeGroceryListbox(_groceryList, 'GroceryList'),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Recently Bought Items',
                    ),
                    Expanded(
                      child: _makeGroceryListbox(_recentList, 'RecentItems'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
