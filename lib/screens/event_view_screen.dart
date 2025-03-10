
import 'package:application_map_todolist/screens/home_screen.dart';
import 'package:application_map_todolist/units/mmfuntion.dart';
import 'package:flutter/material.dart';
import 'package:application_map_todolist/wiggets/event_Editing.dart';
import 'package:application_map_todolist/models/event_model.dart';
import 'package:application_map_todolist/models/type_model.dart';
import 'package:provider/provider.dart';
import 'package:application_map_todolist/providers/event_provider.dart';
import 'package:application_map_todolist/units/utils.dart';

class EventViewing extends StatefulWidget {
  const EventViewing({super.key, required this.events});
  final Event events;

  @override
  State<EventViewing> createState() => _EventViewingState();
}

class _EventViewingState extends State<EventViewing> {
  late Event event;
  Type? type ;
  @override
  void initState() {
    super.initState();
    event = widget.events;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(color: Color.fromARGB(255, 98, 197, 162)),
        actions: buildViewingActions(context, event),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 16, bottom: 70, left: 16, right: 16),
        child: Column(
          children: [
          buildTitle(event),
          const SizedBox(height: 10),
          buildImage(event),
          const SizedBox(height: 10),
          buildDateTime(event),
          const SizedBox(height: 20),
          buildDescriotion(event),
          ],
        )
      ),
      floatingActionButton: FloatingActionButton(
      onPressed: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              onNavigate: 2,
              markerId: event.markerId,
            ),
          ),
        );
      },
      child: Icon(Icons.my_location, color: Colors.white),
      backgroundColor: const Color.fromARGB(255, 98, 197, 162),
      shape: CircleBorder()
    ),
    );
  }

  Widget buildTitle(Event event) {
    return Container(
      width: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Text(event.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
    );
  }

  Widget buildImage(Event event) {
    return Container(
      padding: EdgeInsets.all(5),
      height: 200,
      width: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Mfuntion.resolveImageWidget(imagePath: event.image),
    );
  }

  Widget buildDateTime(Event event) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color.fromARGB(255, 147, 101, 37),
          ),
          child: Icon(Icons.timer, color: const Color.fromARGB(255, 234, 210, 132), size: 25,),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 70,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildDate(event.from),
                Icon(Icons.keyboard_arrow_right, size: 50, color: const Color.fromARGB(255, 147, 101, 37),),
                buildDate(event.to),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDate(DateTime date) {
    return Container(
      child: Row(
        children: [
          Text(
            Utils.toDateTime(date),
            style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget buildDescriotion(Event event) {
    final provider = Provider.of<EventProvider>(context, listen: false);
    type = provider.getTypeById(event.typeId);
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildHeader(text: 'รายละเอียด', icon: Icons.assignment),
          const SizedBox(height: 10),
          buildText(text: event.description == '' ? 'ไม่ได้ระบุรายละเอียด' : event.description),
          const SizedBox(height: 20),
          buildHeader(text: 'ประเภท', icon: Icons.bookmark),
          const SizedBox(height: 10),
          buildText(text: 'ชื่อ: ${type!.name}   ระยะเวลา: ${type!.duration}'),
          const SizedBox(height: 20),
          buildHeader(text: 'สี', icon: Icons.color_lens),
          const SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.only(left: 35),
            child: Container(
            height: 20,
            width: 50,
            decoration: BoxDecoration(
              color: Color(event.backgroundColor),
              borderRadius: BorderRadius.circular(10)
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget buildText({required String text}) {
    return Padding(
      padding: EdgeInsets.only(left: 35),
      child: Text(text, style: TextStyle(fontSize: 17, color: const Color.fromARGB(255, 87, 87, 87))),
    );
  }

  Widget buildHeader({required String text, required IconData icon}) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: const Color.fromARGB(255, 147, 101, 37)
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color.fromARGB(255, 242, 224, 163), size: 20,),
            ],
          )
        ),
      const SizedBox(width: 10),
      Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  List<Widget> buildViewingActions(BuildContext context, Event event) {
    return [
      IconButton(
        icon: Icon(Icons.edit, color: const Color.fromARGB(255, 98, 197, 162),),
        onPressed: () async { 
          final edit = await showDialog(
            context: context,
              builder: (context) => EventEditing(event: event, image: event.image, markerId: event.markerId),
          );
          if (edit == 'true' || edit == 'save') {
            Navigator.of(context).pop(edit);
          }
        }
      ),
      IconButton(
        icon: Icon(Icons.delete, color: Color.fromARGB(255, 98, 197, 162),),
        onPressed: () {
          _confirmDelete(event);
        }
      ),
    ];
  }

  void _confirmDelete(Event event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('ยืนยันการลบ'),
            ],
          ),
          content: Text('กิจกรรม ${event.title}', style: TextStyle(fontSize: 16),),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CloseButton(
                  color: const Color.fromARGB(255, 98, 197, 162),
                ),
                IconButton(
                  icon: Icon(Icons.done, color: const Color.fromARGB(255, 98, 197, 162)),
                  onPressed: () {
                    final provider = Provider.of<EventProvider>(context, listen: false);
                    provider.deleteEvent(event.id);
                    Navigator.pop(context);
                    Navigator.of(context).pop('true');
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
