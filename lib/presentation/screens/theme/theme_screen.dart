import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventarium/data/theme_provider.dart';

class ThemeScreen extends ConsumerWidget {
  static const name = 'theme_selection_screen';
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    bool isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selección de tema'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(themeNotifierProvider.notifier).toggleDarkMode();
            },
            icon:
                isDarkMode
                    ? const Icon(Icons.dark_mode)
                    : const Icon(Icons.light_mode),
          ),
        ],
      ),
      body: const _ThemeSelectionView(),
    );
  }
}

class _ThemeSelectionView extends ConsumerWidget {
  const _ThemeSelectionView();

  @override
  Widget build(BuildContext context, ref) {
    final List<Color> colorList = ref.watch(colorListProvider);
    final int selectedColor = ref.watch(themeNotifierProvider).selectedColor;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DropdownButtonFormField<int>(
        value: selectedColor,
        decoration: const InputDecoration(
          labelText: 'Seleccionar color',
          border: OutlineInputBorder(),
        ),
        items: List.generate(
          colorList.length,
          (index) => DropdownMenuItem(
            value: index,
            child: Row(
              children: [
                CircleAvatar(backgroundColor: colorList[index], radius: 10),
                const SizedBox(width: 8),
                Text(
                  '#${colorList[index].toARGB32().toRadixString(16).toUpperCase()}',
                ),
              ],
            ),
          ),
        ),
        onChanged: (value) {
          if (value != null) {
            ref.read(themeNotifierProvider.notifier).changeColorTheme(value);
          }
        },
      ),
    );
  }
}
