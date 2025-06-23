import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/article_repository_provider.dart';
import 'package:inventarium/domain/article.dart';
import 'package:inventarium/domain/article_status.dart';

class ArticleListCard extends ConsumerWidget {
  final Article article;
  final bool showCheckbox;
  final bool? checkboxValue;
  final ValueChanged<bool?>? onCheckboxChanged;
  final bool showImage;

  const ArticleListCard({
    super.key,
    required this.article,
    required this.showCheckbox,
    this.checkboxValue,
    this.onCheckboxChanged,
    this.showImage = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool hasRetried = false;

    String? fallbackUrl = article.imageUrl;

    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (showImage)
                        if (article.imageUrl != null &&
                            article.imageUrl!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: StatefulBuilder(
                                builder:
                                    (context, setState) => Image.network(
                                      fallbackUrl!,
                                      fit: BoxFit.contain,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        if (!hasRetried &&
                                            error.toString().contains('403')) {
                                          hasRetried = true;

                                          // Reintenta una sola vez
                                          ref
                                              .read(
                                                articleSearchNotifierProvider
                                                    .notifier,
                                              )
                                              .loadImageWithTokenRetry(article)
                                              .then((newUrl) {
                                                if (newUrl != null) {
                                                  setState(
                                                    () => fallbackUrl = newUrl,
                                                  );
                                                } else {
                                                  setState(
                                                    () => fallbackUrl = null,
                                                  );
                                                }
                                              });
                                        }

                                        return Image.asset(
                                          'assets/images/no_image.png',
                                          fit: BoxFit.contain,
                                        );
                                      },
                                    ),
                              ),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: Image.asset(
                                'assets/images/no_image.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.description,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('SKU: ${article.sku}'),
                            Text('Stock: ${article.stock}'),
                            if (article.price1 != null)
                              Text(
                                'Precio 1: \$${article.price1!.toStringAsFixed(2)}',
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (showCheckbox && article.status == ArticleStatus.active.name)
              Positioned(
                right: 8,
                bottom: 8,
                child: Checkbox(
                  value: checkboxValue ?? false,
                  onChanged: onCheckboxChanged,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
