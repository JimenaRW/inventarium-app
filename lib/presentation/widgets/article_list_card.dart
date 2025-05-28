import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/domain/article.dart';

class ArticleListCard extends ConsumerWidget {
  final Article article;
  final bool showCheckbox;
  final bool? checkboxValue;
  final ValueChanged<bool?>?
  onCheckboxChanged;

  const ArticleListCard({
    super.key,
    required this.article,
    required this.showCheckbox,
    this.checkboxValue,
    this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox condicional
              if (showCheckbox)
                Column(
                  children: [
                    CheckboxListTile(
                      value: checkboxValue ?? false,
                      onChanged: onCheckboxChanged,
                      contentPadding:
                          EdgeInsets.zero, // Elimina padding interno
                      controlAffinity:
                          ListTileControlAffinity
                              .leading, // Checkbox a la izquierda
                    ),
                  ],
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.descripcion,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Resto de la información
                  Text('SKU: ${article.sku}'),
                  Text('Stock: ${article.stock}'),
                  if (article.precio1 != null)
                    Text('Precio: \$${article.precio1!.toStringAsFixed(2)}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
