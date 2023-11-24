import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyCalendar(),
    );
  }
}

class MyCalendar extends StatefulWidget {
  @override
  _MyCalendarState createState() => _MyCalendarState();
}

class _MyCalendarState extends State<MyCalendar> {
  late CalendarController _calendarController;

  // Dummy data: Replace this with your actual data
  Map<DateTime, List<String>> events = {
    DateTime(2023, 6, 1): ['😊', '🌞'],
    DateTime(2023, 6, 5): ['😐', '🌧'],
    DateTime(2023, 6, 15): ['😔', '⛅'],
    DateTime(2023, 6, 30): ['😃', '🎉'],
  };

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emoji Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: DateTime.now(),
            firstDay: DateTime(2023, 1, 1),
            lastDay: DateTime(2023, 12, 31),
            onDaySelected: (date, events, _) {
              // Handle day selection if needed
            },
            builders: CalendarBuilders(
              markersBuilder: (context, date, events, holidays) {
                final children = <Widget>[];

                if (events.isNotEmpty) {
                  children.add(
                    Positioned(
                      right: 1,
                      bottom: 1,
                      child: _buildEventMarker(events),
                    ),
                  );
                }

                return children;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventMarker(List<String> events) {
    // Customize the appearance of the emoji marker
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blueAccent,
      ),
      width: 20.0,
      height: 20.0,
      child: Center(
        child: Text(
          events.first, // Only show the first emoji for simplicity
          style: TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }
}
