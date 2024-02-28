import 'package:flutter/material.dart';
import 'package:selectable_draggable_listbox/selectable_draggable_listbox.dart';

class ListboxItem<T> extends TemplatedListboxItem<T> {
  ListboxItem({
    super.key,
    required super.item,
    required this.label,
    super.onSelect,
    super.isDragging,
    super.customDecoration,
    required this.textStyle,
  }) : super(
          childTemplate: (item) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  label,
                  style: textStyle,
                ),
              ],
            ),
          ),
        );

  final String label;
  final TextStyle? textStyle;
}
