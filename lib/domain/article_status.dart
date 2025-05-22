// todo cambiar nombre a Status
enum ArticleStatus {
  active,
  inactive,
  suspended;

  @override
  String toString() {
    switch (this) {
      case ArticleStatus.active:
        return 'active';
      case ArticleStatus.inactive:
        return 'inactive';
      case ArticleStatus.suspended:
        return 'suspended';
    }
  }
}
