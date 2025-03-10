import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:application_map_todolist/providers/event_provider.dart';
import 'package:application_map_todolist/models/event_model.dart';
import 'package:application_map_todolist/models/event_data_source.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:application_map_todolist/screens/event_view_screen.dart';

class TasksWidget extends StatefulWidget {
  final bool taskToday ;
  const TasksWidget({super.key, this.taskToday = false});

  @override
  State<TasksWidget> createState() => _TasksWidgetState();
}

class _TasksWidgetState extends State<TasksWidget> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventProvider>(context) ;
    final selectedEvents = provider.eventsOfSelectedDate ;
    return !widget.taskToday
      ? buildTask(provider)
      : selectedEvents.isEmpty
        ? Center(child: Text('วันนี้ไม่มีกิจกรรม', style: TextStyle(fontSize: 18),),)
        : buildTask(provider);
  }

  Widget buildTask(EventProvider provider) =>
        SfCalendarTheme(
      data: SfCalendarThemeData(
        timeTextStyle: TextStyle(fontSize: 16 , color: Colors.black),
      ),
      child: SfCalendar(
        view: CalendarView.timelineDay,
        timeSlotViewSettings: TimeSlotViewSettings(
          timeInterval: const Duration(hours: 1),
          timeIntervalWidth: 70,
          timeFormat: 'HH:mm',
          timeTextStyle: const TextStyle(
            fontSize: 15,
            color: Colors.black,
          ),
        ),

        viewHeaderStyle: ViewHeaderStyle(
          dayTextStyle: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.bold, // ตัวหนา
            color: Colors.black, // สีข้อความ
          ),
          dateTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold, // ตัวหนา
            color: Colors.black, // สีข้อความวันที่
          ),
        ),
        cellBorderColor: const Color.fromARGB(255, 234, 210, 132),
        todayHighlightColor: const Color.fromARGB(255, 147, 101, 37),
        dataSource: EventDataSource(provider.events),
        initialDisplayDate: widget.taskToday ? DateTime.now() : provider.selectedDate ,
        appointmentBuilder: appointmentBuilder ,
        headerHeight: 0,
        onTap: (details) {
          if (details.appointments != null && details.appointments!.isNotEmpty){
            final event = details.appointments!.first as Event;
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => EventViewing(events:event),
            ));
          }
        },
      ),
    );

  Widget appointmentBuilder (
    BuildContext context ,
    CalendarAppointmentDetails details ,
  ) {
    final event = details.appointments.first ;
    final imagePath = event.image;
    final isAsset1 = imagePath.startsWith('assets/');
    final isAsset2 = imagePath.startsWith('data:image');
    
    return Container(
      margin: EdgeInsets.only(top: 3),
      width: details.bounds.width,
      height: details.bounds.height,
      decoration: BoxDecoration(
        color: Color(event.backgroundColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Row(
          children: [
            Center(
            child: isAsset1
              ? Image.asset(
                event.image,
                width: 30,
                height: 30,
                fit: BoxFit.cover,
              )
              : isAsset2
                ? Image.memory(
                    width: 30,
                    height: 30,
                    Uint8List.fromList(
                        base64Decode(imagePath.split(',').last)),
                    fit: BoxFit.cover,
                  )
                : Icon(
                    Icons.event,
                    color: Colors.white,
                  ),
          ),
          const SizedBox(width: 3),
          Expanded(
            child: Text(
              event.title,
              maxLines: 1, // จำนวนบรรทัดสูงสุด
              overflow: TextOverflow.ellipsis, // ถ้าข้อความเกิน ให้แสดง ...
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ],
        )
      ),
    ) ;
  }
}
