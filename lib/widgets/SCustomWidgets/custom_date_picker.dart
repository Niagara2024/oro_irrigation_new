import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerField extends StatefulWidget {
  final DateTime value;
  final void Function(DateTime) onChanged; // Callback function
  const DatePickerField({Key? key, required this.value, required this.onChanged}) : super(key: key);

  @override
  _DatePickerFieldState createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  TextEditingController dateController = TextEditingController();
  final dateFormat = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    dateController.text = dateFormat.format(widget.value);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        dateController.text = dateFormat.format(picked);
        widget.onChanged(picked); // Call the callback with the updated value
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Text(dateController.text, style: Theme.of(context).textTheme.bodyMedium,),
    );
  }
}
