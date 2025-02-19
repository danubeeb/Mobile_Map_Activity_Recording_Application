import 'package:application_map_todolist/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<Event>appointments) {
    this.appointments = appointments ;
  }

  Event getEvent(int index) => appointments![index] as Event ; 

  @override
  DateTime getStartTime(int index) {
    return getEvent(index).from;
  }

  @override
  DateTime getEndTime(int index) {
    return getEvent(index).to;
  }

  @override
  String getSubject(int index) {
    return getEvent(index).title;
  }

  @override
  Color getColor(int index) {
    return Color(getEvent(index).backgroundColor);
  }

}