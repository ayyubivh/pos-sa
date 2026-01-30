import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A simple date/time picker widget to replace the date_time_picker package
/// This uses Flutter's built-in showDatePicker and showTimePicker
class SimpleDateTimePicker extends StatefulWidget {
  final String? initialValue;
  final String? firstDate;
  final String? lastDate;
  final ValueChanged<String>? onChanged;
  final InputDecoration? decoration;
  final DateTimePickerType type;

  const SimpleDateTimePicker({
    super.key,
    this.initialValue,
    this.firstDate,
    this.lastDate,
    this.onChanged,
    this.decoration,
    this.type = DateTimePickerType.dateTime,
  });

  @override
  State<SimpleDateTimePicker> createState() => _SimpleDateTimePickerState();
}

class _SimpleDateTimePickerState extends State<SimpleDateTimePicker> {
  late TextEditingController _controller;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      try {
        _selectedDate = DateTime.parse(widget.initialValue!);
        _selectedTime = TimeOfDay.fromDateTime(_selectedDate!);
      } catch (e) {
        // Invalid date format
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: widget.firstDate != null
          ? DateTime.parse(widget.firstDate!)
          : DateTime(2000),
      lastDate: widget.lastDate != null
          ? DateTime.parse(widget.lastDate!)
          : DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        if (widget.type == DateTimePickerType.dateTime) {
          _selectTime(context);
        } else {
          _updateValue();
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _updateValue();
      });
    }
  }

  void _updateValue() {
    if (_selectedDate != null) {
      String formattedValue;
      if (widget.type == DateTimePickerType.dateTime && _selectedTime != null) {
        final dateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );
        formattedValue = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
      } else {
        formattedValue = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      }
      _controller.text = formattedValue;
      widget.onChanged?.call(formattedValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration:
          widget.decoration ??
          const InputDecoration(
            labelText: 'Select Date/Time',
            suffixIcon: Icon(Icons.calendar_today),
          ),
      readOnly: true,
      onTap: () => _selectDate(context),
    );
  }
}

enum DateTimePickerType { date, time, dateTime }
