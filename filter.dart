import 'package:flutter/material.dart';

enum FilterOption { lastHour, today, all }

class FilterPage extends StatelessWidget {
  final FilterOption selectedFilter;
  final Function(FilterOption) onFilterSelected;

  const FilterPage({super.key, required this.selectedFilter, required this.onFilterSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Filter"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFilterOption(context, "Last Hour", FilterOption.lastHour),
          _buildFilterOption(context, "Today", FilterOption.today),
          _buildFilterOption(context, "All", FilterOption.all),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
      ],
    );
  }

  Widget _buildFilterOption(BuildContext context, String label, FilterOption option) {
    return RadioListTile(
      title: Text(label),
      value: option,
      groupValue: selectedFilter,
      onChanged: (value) {
        onFilterSelected(value!);
        Navigator.pop(context);
      },
    );
  }
}

// Function to generate Firestore Query based on filter
DateTime? getFilterDate(FilterOption option) {
  DateTime now = DateTime.now();
  switch (option) {
    case FilterOption.lastHour:
      return now.subtract(const Duration(hours: 1));
    case FilterOption.today:
      return DateTime(now.year, now.month, now.day);
    case FilterOption.all:
      return null;
  }
}
