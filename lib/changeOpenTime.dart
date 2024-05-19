import 'package:fixpert/home.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class ChangeOpenTimePage extends StatefulWidget {
  const ChangeOpenTimePage({Key? key}) : super(key: key);

  @override
  State<ChangeOpenTimePage> createState() => _ChangeOpenTimePageState();
}

class _ChangeOpenTimePageState extends State<ChangeOpenTimePage> {
  late TimeOfDay openTime = TimeOfDay(hour: 9, minute: 0); // Initial open time
  late TimeOfDay closeTime = TimeOfDay(hour: 17, minute: 0); // Initial close time

  Future<void> updateOpenCloseTime() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String id = sp.getString('user_id') ?? "";

    // Format the open and close time values as strings
    String formattedOpenTime = _formatTime(openTime);
    String formattedCloseTime = _formatTime(closeTime);

    final url = "https://switch.unotelecom.com/fixpert/updateOpenCloseTime.php?worker_id=${id}&open_time=$formattedOpenTime&close_time=$formattedCloseTime";
    print("fetching $url");
    final request = await http.get(Uri.parse(url));
    if (request.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Time updated!")));
    }
  }
  String _formatTime(TimeOfDay timeOfDay) {
    String period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
    int hour = timeOfDay.hourOfPeriod == 0 ? 12 : timeOfDay.hourOfPeriod;
    String hourStr = hour < 10 ? '0$hour' : '$hour';
    String minuteStr = timeOfDay.minute < 10 ? '0${timeOfDay.minute}' : '${timeOfDay.minute}';
    return '$hourStr:$minuteStr $period';
  }
  Future<void> selectOpenTime() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: openTime,
    );
    if (selectedTime != null) {
      setState(() {
        openTime = selectedTime;
      });
    }
  }

  Future<void> selectCloseTime() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: closeTime,
    );
    if (selectedTime != null) {
      setState(() {
        closeTime = selectedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Open and Close Time'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: selectOpenTime,
              icon: Icon(Icons.access_time),
              label: Text('Select Open Time'),
            ),
            SizedBox(height: 20),
            Text(
              'Selected Open Time: ${_formatTime(openTime)}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: selectCloseTime,
              icon: Icon(Icons.access_time),
              label: Text('Select Close Time'),
            ),
            SizedBox(height: 20),
            Text(
              'Selected Close Time: ${_formatTime(closeTime)}',
              style: TextStyle(fontSize: 16),
            ),
            ElevatedButton(onPressed: () {
              updateOpenCloseTime();
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Home(neededPage: 3,),));
            }, child: Text("update"))
          ],
        ),
      ),
    );
  }

//   String _formatTime(TimeOfDay timeOfDay) {
//     final now = DateTime.now();
//     final time = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
//     return DateFormat.jm().format(time);
//   }
}
