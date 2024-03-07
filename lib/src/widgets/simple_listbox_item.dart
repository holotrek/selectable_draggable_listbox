import 'package:flutter/material.dart';
import 'package:selectable_draggable_listbox/src/widgets/abstract_listbox_item.dart';

/// A simple widget containing a Text element for a Listbox item template
class SimpleListboxItem<T> extends AbstractListboxItem<T> {
  /// A simple widget containing a Text element for a Listbox item template
  SimpleListboxItem({
    super.key,
    required super.item,
    required this.label,
    super.eventManager,
    super.onSelect,
    super.isDragging,
    super.customDecoration,
    this.textStyle,
  }) : super(
          childTemplate: (context, item) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  label,
                  style: textStyle ?? Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ),
        );

  /// The text label to show for this item
  final String label;

  /// Override the text style for this item
  final TextStyle? textStyle;
}
