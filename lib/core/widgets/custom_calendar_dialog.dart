import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';

class CustomCalendarDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const CustomCalendarDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<CustomCalendarDialog> createState() => _CustomCalendarDialogState();
}

class _CustomCalendarDialogState extends State<CustomCalendarDialog> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
    _selectedDate = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
    );
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  List<Widget> _buildCalendarDays() {
    final List<Widget> dayWidgets = [];
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );

    // Weekday of 1st day (1 = Monday, 7 = Sunday)
    // Sunday is index 0 in our headers list: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
    final emptySlots = firstDayOfMonth.weekday % 7;

    // Days in previous month
    final prevMonth = _currentMonth.month == 1 ? 12 : _currentMonth.month - 1;
    final prevYear = _currentMonth.month == 1
        ? _currentMonth.year - 1
        : _currentMonth.year;
    final daysInPrevMonth = _getDaysInMonth(prevYear, prevMonth);

    // Add greyed out days from previous month
    for (int i = emptySlots - 1; i >= 0; i--) {
      final day = daysInPrevMonth - i;
      dayWidgets.add(_buildDayCell(dayText: day.toString(), isDisabled: true));
    }

    // Days in current month
    final daysInCurrentMonth = _getDaysInMonth(
      _currentMonth.year,
      _currentMonth.month,
    );
    for (int day = 1; day <= daysInCurrentMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final isSelected =
          date.year == _selectedDate.year &&
          date.month == _selectedDate.month &&
          date.day == _selectedDate.day;

      final isOutOfRange =
          date.isBefore(widget.firstDate) || date.isAfter(widget.lastDate);

      dayWidgets.add(
        _buildDayCell(
          dayText: day.toString(),
          isSelected: isSelected,
          isDisabled: isOutOfRange,
          onTap: isOutOfRange
              ? null
              : () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
        ),
      );
    }

    // Fill remaining slots for a full grid if needed
    final totalSlots = dayWidgets.length;
    final remainingSlots = (7 - (totalSlots % 7)) % 7;
    for (int day = 1; day <= remainingSlots; day++) {
      dayWidgets.add(_buildDayCell(dayText: day.toString(), isDisabled: true));
    }

    return dayWidgets;
  }

  Widget _buildDayCell({
    required String dayText,
    bool isSelected = false,
    bool isDisabled = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF065F46) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            dayText,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : (isDisabled
                        ? AppColors.outline.withValues(alpha: 0.5)
                        : AppColors.textPrimary),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> monthsFull = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final monthYearText =
        '${monthsFull[_currentMonth.month - 1]} ${_currentMonth.year}';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Month Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.keyboard_arrow_left,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: _prevMonth,
                ),
                Text(
                  monthYearText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.keyboard_arrow_right,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: _nextMonth,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Weekday Headers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map(
                    (d) => Text(
                      d,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            // Grid of Days
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: _buildCalendarDays(),
            ),
            const SizedBox(height: 24),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Get.back(result: _selectedDate),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF065F46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Pilih',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
