// frontend/lib/widgets/common/filter_chips.dart
import 'package:flutter/material.dart';

class FilterChips extends StatelessWidget {
  final String title;
  final List<String> chips;
  final String selected;
  final Function(String) onSelected;

  const FilterChips({
    super.key,
    required this.title,
    required this.chips,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips.map((chip) {
            final isSelected = chip == selected;
            return FilterChip(
              label: Text(chip),
              selected: isSelected,
              onSelected: (_) => onSelected(chip),
              backgroundColor: Colors.grey[100],
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: StadiumBorder(
                side: BorderSide(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}