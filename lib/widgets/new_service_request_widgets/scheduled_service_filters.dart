// lib/widgets/scheduled_service_filters.dart
import 'package:flutter/material.dart';

class ScheduledServiceFilters extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const ScheduledServiceFilters({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'In Progress', 'Delayed', 'Completed'];

    return Container(
      height: 50,
      color: Colors.grey[200],
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;

          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 16 : 4,
              right: index == filters.length - 1 ? 16 : 4,
              top: 8,
              bottom: 8,
            ),
            child: GestureDetector(
              onTap: () => onFilterChanged(filter),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: isSelected ? Border.all(color: Colors.grey[300]!) : null,
                ),
                child: Center(
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}