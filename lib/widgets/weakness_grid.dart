import 'package:flutter/material.dart';
import '../utils/type_chart.dart';
import '../utils/type_colors.dart';

class WeaknessGrid extends StatelessWidget {
  final List<String> types;

  const WeaknessGrid({super.key, required this.types});

  @override
  Widget build(BuildContext context) {
    final weakMap = TypeChart.getFullWeaknessMap(types);

    final grouped = <double, List<String>>{};
    weakMap.forEach((type, mult) {
      grouped.putIfAbsent(mult, () => []).add(type);
    });

    final sections = [4.0, 2.0, 0.5, 0.25, 0.0];
    final labels = {
      4.0: '4×',
      2.0: '2×',
      0.5: '½×',
      0.25: '¼×',
      0.0: '0×',
    };
    final sectionColors = {
      4.0: Colors.red.shade700,
      2.0: Colors.orange.shade700,
      0.5: Colors.green.shade600,
      0.25: Colors.blue.shade600,
      0.0: Colors.grey.shade700,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections
          .where((m) => (grouped[m]?.isNotEmpty ?? false))
          .map((mult) {
        final typeList = grouped[mult]!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: sectionColors[mult],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      labels[mult]!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    mult == 0.0
                        ? 'Inmune'
                        : mult < 1.0
                            ? 'Resistencia'
                            : 'Debilidad',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: typeList
                    .map((t) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: TypeColors.of(t).withOpacity(0.85),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            t.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
