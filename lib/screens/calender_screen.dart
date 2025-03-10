import 'package:flutter/material.dart';
import 'package:application_map_todolist/models/event_data_source.dart';
import 'package:application_map_todolist/providers/event_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:application_map_todolist/wiggets/task_widget.dart';

class CalendarApp extends StatefulWidget {
  const CalendarApp({super.key});

  @override
  State<CalendarApp> createState() => _CalendarAppState();
}

class _CalendarAppState extends State<CalendarApp> {
  int viewMode = 0;
  final CalendarController _calendarController = CalendarController();

  @override
  Widget build(BuildContext context) {
    final events = Provider.of<EventProvider>(context).events;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.09,
        flexibleSpace: buildAppBar(),
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 60, left: 8, right: 8),
            decoration: BoxDecoration(
              color: Colors.white
            ),
            child: SfCalendar(
              key: ValueKey(viewMode),
              controller: _calendarController,
              view: CalendarView.month,
              headerStyle: const CalendarHeaderStyle(
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18
                )
              ),
              viewHeaderStyle: ViewHeaderStyle(
                dayTextStyle: TextStyle(
                  fontSize: 16,
                  color: const Color.fromARGB(255, 176, 139, 17),
                ),
              ),
              headerDateFormat: 'MMM yyyy',
              timeSlotViewSettings: TimeSlotViewSettings(
                  timeFormat: 'H.mm',
              ),
              dataSource: EventDataSource(events),
              firstDayOfWeek: 1,
              cellBorderColor: const Color.fromARGB(255, 234, 210, 132),
              todayHighlightColor: const Color.fromARGB(255, 147, 101, 37),
              todayTextStyle: TextStyle(fontWeight: FontWeight.bold),
              onTap: (details) {
                final provider = Provider.of<EventProvider>(context, listen: false);
                provider.setDate(details.date!);
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    insetPadding: EdgeInsets.only(top: 230),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // กำหนดขอบมนเป็น 0
                    ),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      height: MediaQuery.of(context).size.height * 0.5, // ความสูงเต็มหน้าจอ
                      width: MediaQuery.of(context).size.width * 0.92, // ความกว้างเต็มหน้าจอ
                      child: TasksWidget(),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 140, right: 140, top:10),
            height: 30,
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _calendarController.displayDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  _calendarController.displayDate = pickedDate;
                }
              },
            ),
          ),
          Positioned(
            top: -6,
            left: MediaQuery.of(context).size.width * 0.22,
            child:  IconButton(
              icon: const Icon(Icons.arrow_left, color: Color.fromARGB(255, 147, 101, 37), size: 40),
              onPressed: () {
                _calendarController.backward!();
              },
            ),
          ),
          Positioned(
            top: -6,
            right: MediaQuery.of(context).size.width * 0.22,
            child:  IconButton(
              icon: const Icon(Icons.arrow_right, color: Color.fromARGB(255, 147, 101, 37), size: 40),
              onPressed: () {
                _calendarController.forward!();
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget buildAppBar() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/image_calendar.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 45,
          right: 12,
          child:  Container(
            height: 36,
            padding: EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 147, 101, 37),
              borderRadius: BorderRadius.circular(9)
            ),
            child: ToggleButtons(
              isSelected: [viewMode == 0, viewMode == 1],
              onPressed: (int index) {
                setState(() {
                  viewMode = index;
                });
                _calendarController.view = viewMode == 0 ? CalendarView.month : CalendarView.week;
              },
              borderColor: const Color.fromARGB(255, 147, 101, 37),
              selectedBorderColor: const Color.fromARGB(255, 73, 150, 123),
              borderWidth: 2,
              borderRadius: BorderRadius.circular(8.0),
              color: const Color.fromARGB(255, 109, 109, 109),
              fillColor: const Color.fromARGB(255, 98, 197, 162),
              constraints: BoxConstraints(
                minHeight: 30.0,
                minWidth: 40.0,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Text('เดือน', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('สัปดาห์', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}




