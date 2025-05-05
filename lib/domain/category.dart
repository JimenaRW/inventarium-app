class Category {
  int categoryId;
  String description;

  Category({
    required this.categoryId,
    required this.description});
  

  @override
  String toString() => 'Categoría: $description';
}