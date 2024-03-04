/// Wrapper around an item in the list that tracks whether it is currently selected
class ListItem<T> {
  final T data;
  bool isSelected = false;
  bool isPlaceholder = false;
  ListItem(this.data);

  ListItem.asPlaceholder(ListItem<T> original)
      : data = original.data,
        isSelected = original.isSelected,
        isPlaceholder = true;
}
