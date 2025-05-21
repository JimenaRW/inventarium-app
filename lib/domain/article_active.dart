enum ArticleActive {
  activo,
  inactivo,
  suspendido;

  @override
  String toString() {
    switch (this) {
      case ArticleActive.activo:
        return 'disponible';
      case ArticleActive.inactivo:
        return 'retirado';
      case ArticleActive.suspendido:
        return 'no disponible';
    }
  }
}
