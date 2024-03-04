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

  final _recentList = [
    GroceryItem(name: 'Apples'),
    GroceryItem(name: 'Bread'),
  ].forListbox().toList();

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
                    Text(
                      'Grocery List',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const Text('Features: Multiselect, Reorder, Drag From'),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          Widget makeItemTemplate(
                              context, index, item, onSelect, isDragging) {
                            return SimpleListboxItem(
                              key: Key('$index'),
                              item: item,
                              label: isDragging
                                  ? item.data.name
                                  : '${index + 1}. ${item.data.name}',
                              onSelect: onSelect,
                              isDragging: isDragging,
                            );
                          }

                          return Listbox(
                            key: const Key('GroceryList'),
                            items: _groceryList,
                            onSelect: (itemsSelected) {
                              debugPrint(
                                  'Selected: ${itemsSelected.map((e) => e.data.name).join(',')}');
                              setState(() {
                                for (var item in _groceryList) {
                                  item.isSelected =
                                      itemsSelected.contains(item);
                                }
                              });
                            },
                            onReorder: (oldIndex, newIndex) {
                              debugPrint(
                                  'Moving item from $oldIndex to $newIndex');
                              setState(() {
                                final element = _groceryList[oldIndex];
                                _groceryList.removeAt(oldIndex);
                                _groceryList.insert(newIndex, element);
                              });
                            },
                            itemTemplate: (context, index, item, onSelect) =>
                                makeItemTemplate(
                                    context, index, item, onSelect, false),
                            dragTemplate: (context, index, item) =>
                                makeItemTemplate(
                                    context, index, item, null, true),
                            enableDebug: true,
                          );
                        },
                      ),
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
                            onSelect: (itemsSelected) {
                              debugPrint(
                                  'Selected: ${itemsSelected.map((e) => e.data.name).join(',')}');
                              setState(() {
                                for (var item in _recentList) {
                                  item.isSelected =
                                      itemsSelected.contains(item);
                                }
                              });
                            },
                            itemTemplate: (context, index, item, onSelect) {
                              return SimpleListboxItem(
                                key: Key('$index'),
                                item: item,
                                label: item.data.name,
                                onSelect: onSelect,
                              );
                            },
                            onDrop: (itemsDropped, index) {
                              debugPrint(
                                  'Dropped items ${itemsDropped.map((e) => e.data.name).join(',')} into index $index');
                            },
                            dropPlaceholderTemplate:
                                (context, index, item, itemsToBeDropped) {
                              var itemsLength = itemsToBeDropped.length;
                              var label = itemsLength > 1
                                  ? '$itemsLength new items...'
                                  : itemsLength > 0
                                      ? itemsToBeDropped.first.data.name
                                      : '';
                              return SimpleListboxItem(
                                key: Key('$index'),
                                item: item,
                                label: label,
                              );
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
            ),
          ],
        ),
      ),
    );
  }
}
