/// Wrapper around an item in the list that tracks whether it is currently selected
class ListItem<T> {
  final T data;
  bool isSelected = false;
  ListItem(this.data);
}
