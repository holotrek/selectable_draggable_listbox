[![Pub][pub_badge]][pub_link]
[![License: MIT][license_badge]][license_link]

# selectable_draggable_listbox

Listbox with multiselect, drag & drop between lists, and reorder built in.

## Features

- Bind your data to a listview of custom widget
  - Simple text item widget -or-
  - Templated list item widget for more cusomizability
- Multi-select items
  - Shift-click to select items in sequence
  - Ctrl/Cmd-click to select individual items
  - Single-select only option available
- Reorderable
  - Click & drag the "three lines" icon to reorder item
- Drag & Drop
  - Drag items from/to different lists
  - Each list may independently be a draggable, drop target, or both

[![Feature Demo](https://github.com/holotrek/selectable_draggable_listbox/blob/main/doc/images/feature_demo.gif?raw=true "Feature Demo")](./doc/images/feature_demo.gif)

## Getting started

1. Add the latest version of this package:

- Run `flutter pub add selectable_draggable_listbox` -or-
- Edit `pubspec.yaml` and then run `flutter pub get`:

```yaml
dependencies:
  selectable_draggable_listbox: ^latest_version
```

2. Import the package

```
import 'package:selectable_draggable_listbox/selectable_draggable_listbox.dart';
```

## Usage

```dart
// Create your list and transform it to track selected items (list can be complex objects instead):
final myList = ['Apples','Cheese','Bread','Milk'].forListbox().toList();

// Create the listbox widget
return Listbox(
  items: myList,
  itemTemplate: (context, eventManager, index, item, onSelect) {
    // Define the template used for each listitem
    return SimpleListboxItem(
      key: Key('$index'), // Key is required for reordering
      item: item,
      label: item.data,
      eventManager: eventManager,
      onSelect: onSelect,
    );
  },
  onSelect: (itemsSelected) {
    // React to items selected
    // Note: (value of isSelected is not set automatically by Listbox,
    //  due to not knowing how your state is handled)
    setState(() {
      for (var item in myList) {
        item.isSelected = itemsSelected.contains(item);
      }
    });
  },
  onReorder: (oldIndex, newIndex) {
    // React to item reordered
    setState(() {
      // Note: this is an extension provided by the package
      myList.move(oldIndex, newIndex);
    });
  },
);
```

## Advanced Usage

For more info on additional features like Drag & Drop and Customizable Templates, see examples and API:

- [Example](https://pub.dev/packages/selectable_draggable_listbox/example)
- [API](https://pub.dev/documentation/selectable_draggable_listbox/latest/)

## Support

You can support me by buying me a coffee <a href="https://www.buymeacoffee.com/honeydoodat"><img src="https://www.buymeacoffee.com/assets/img/custom_images/yellow_img.png" alt="Buy me a coffee" width="100" /></a>

And also don't forget to star this package on GitHub <a href="https://github.com/holotrek/selectable_draggable_listbox"><img src="https://img.shields.io/github/stars/holotrek/selectable_draggable_listbox?logo=github&style=flat-square"></a>

[pub_badge]: https://img.shields.io/pub/v/media_key_detector
[pub_link]: https://pub.dev/packages/media_key_detector
[coverage_badge]: coverage_badge.svg
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
