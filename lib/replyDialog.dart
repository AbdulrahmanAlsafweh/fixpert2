import 'package:flutter/material.dart';

class ReplyDialog extends StatefulWidget {
  final Function(String, DateTime,String) onReply;

  const ReplyDialog({Key? key, required this.onReply}) : super(key: key);

  @override
  _ReplyDialogState createState() => _ReplyDialogState();
}

class _ReplyDialogState extends State<ReplyDialog> {
  late TextEditingController priceController;
  late TextEditingController noteController;
  late DateTime selectedDate;
  late TimeOfDay selectedTime;

  @override
  void initState() {
    super.initState();
    noteController = TextEditingController();
    priceController = TextEditingController();
    selectedDate = DateTime.now();
    selectedTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Reply to Quote'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: priceController,
            decoration: InputDecoration(labelText: 'Approximation Price'),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text('Offered Time:'),
              SizedBox(width: 8),
              TextButton(
                onPressed: () => _selectDate(context),
                child: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
              ),
              TextButton(
                onPressed: () => _selectTime(context),
                child: Text('${selectedTime.hour}:${selectedTime.minute}'),
              ),
            ],
          ),
          TextField(
            controller: noteController,
            decoration: InputDecoration(labelText: 'Note'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            String notes = noteController.text;
            String price = priceController.text;
            DateTime selectedDateTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );
            widget.onReply(price, selectedDateTime, notes);
            Navigator.of(context).pop();
          },
          child: Text('Send'),
        ),
      ],
    );
  }
}
