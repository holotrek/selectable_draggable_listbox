import 'package:flutter/material.dart';
import 'package:selectable_draggable_listbox/src/widgets/abstract_listbox_item.dart';

class SimpleListboxItem<T> extends AbstractListboxItem<T> {
  SimpleListboxItem({
    super.key,
    required super.item,
    required this.label,
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

  final String label;
  final TextStyle? textStyle;
}
