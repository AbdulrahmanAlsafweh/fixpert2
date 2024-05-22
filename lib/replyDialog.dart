import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class ReplyDialog extends StatefulWidget {
  final Function(String, DateTime, String ,String ) onReply;
  final bool fastFixing;
  const ReplyDialog({Key? key, required this.onReply ,required this.fastFixing}) : super(key: key);

  @override
  _ReplyDialogState createState() => _ReplyDialogState();
}

class _ReplyDialogState extends State<ReplyDialog> {
  late TextEditingController priceController;
  late TextEditingController noteController;
  late TextEditingController phoneNumberController;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    noteController = TextEditingController();
    priceController = TextEditingController();
    phoneNumberController = TextEditingController();

    selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    priceController.dispose();
    noteController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
              surface: Colors.grey[200]!,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Reply to Quote', style: TextStyle(color: Colors.blueAccent)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Approximation Price',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 12),
            !widget.fastFixing?
            Row(
              children: [
                Text('Offered Date:', style: TextStyle(color: Colors.black)),
                SizedBox(width: 8),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ):
    SizedBox(),
            IntlPhoneField(
              controller: phoneNumberController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(
                  borderSide: BorderSide(),
                ),
              ),
              initialCountryCode: 'LB',
              onChanged: (phone) {
                print(phone.completeNumber);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel', style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: () {
            String notes = noteController.text;
            String price = priceController.text;
            String phoneNumber=phoneNumberController.text;
            widget.onReply(price, selectedDate, notes , phoneNumber);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text('Send'),
        ),
      ],
    );
  }
}
