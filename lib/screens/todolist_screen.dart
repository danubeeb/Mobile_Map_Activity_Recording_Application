
import 'package:application_map_todolist/providers/event_provider.dart';
import 'package:application_map_todolist/screens/event_view_screen.dart';
import 'package:application_map_todolist/models/type_model.dart';
import 'package:application_map_todolist/units/mmfuntion.dart';
import 'package:flutter/material.dart';
import 'package:application_map_todolist/models/event_model.dart';
import 'package:provider/provider.dart';

class ListEvents extends StatefulWidget {
  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<ListEvents> with SingleTickerProviderStateMixin {
  late EventProvider provider;
  String? selectedType;
  String m = '';
  int viewMode = 0;
  late TabController _tabController;
  List<Type> typeEvent = [];
  int eventCount = 0;

  List<Event> events = [];
  List<Event> upcomingEvents = [];
  List<Event> ongoingEvents = [];
  List<Event> finishedEvents = [];

  @override
  void initState() {
    super.initState();
    provider = Provider.of<EventProvider>(context, listen: false);
    _tabController = TabController(length: 4, vsync: this);
    _loadEvents();

    // อัปเดตค่า eventCount ตามแท็บที่เลือก
    _tabController.addListener(() {
      setState(() {
        if (_tabController.index == 1) {
          eventCount = upcomingEvents.length;
        } else if (_tabController.index == 2) {
          eventCount = ongoingEvents.length;
        } else if (_tabController.index == 3) {
          eventCount = finishedEvents.length;
        } else {
          eventCount = events.length;
        }
      });
    });
  }

  Future<void> _loadEvents() async {
    events = provider.events;
    setState(() {
      eventCount = events.length;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getIndicatorColor(int index) {
    switch (index) {
      case 1:
        return const Color.fromARGB(255, 219, 90, 83);
      case 2:
        return const Color.fromARGB(255, 227, 181, 90);
      case 3:
        return const Color.fromARGB(255, 106, 207, 112);
      default:
        return const Color.fromARGB(255, 98, 197, 162);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.23,
        flexibleSpace: buildAppBar(),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: builtTabBar(),
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.07,),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 245, 230, 181)
        ),
        child: Consumer<EventProvider>(
          builder: (context, eventProvider, child) {
            events = selectedType == null
              ? eventProvider.events
              : eventProvider.events
                .where((event) => event.typeId == selectedType)
                .toList();
            upcomingEvents = events
              .where((event) => event.from.isAfter(DateTime.now()))
              .toList();
            ongoingEvents = events
              .where((event) => event.from.isBefore(DateTime.now()) && event.to.isAfter(DateTime.now()))
              .toList();
            finishedEvents = events
              .where((event) => event.to.isBefore(DateTime.now()))
              .toList();
            return TabBarView(
              controller: _tabController,
              children: [
                _buildEventList(events),
                _buildEventList(upcomingEvents),
                _buildEventList(ongoingEvents),
                _buildEventList(finishedEvents),
              ],
            );
          }
        ),
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.075),
        child: FloatingActionButton(
          onPressed: () async {
            typeEvent = provider.types;
            final selected = await _showTypeSelectionDialog(context);
              setState(() {
                selectedType = selected == 'รีเซ็ต' ? null : selected;
              });
          },
          child: Icon(Icons.filter_alt, color: const Color.fromARGB(255, 241, 221, 152),),
          backgroundColor: const Color.fromARGB(255, 147, 101, 37),
          shape: CircleBorder(),
        ),
      ),
    );
  }

  //buildAppBar
  Widget builtTabBar() {
    return Container(
      height: 40,
      margin: EdgeInsets.symmetric(horizontal: 23),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 223, 223, 223),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        labelColor: Colors.white,
        unselectedLabelColor: const Color.fromARGB(255, 109, 109, 109),
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: _getIndicatorColor(_tabController.index),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.zero,
        tabs: [
          Tab(child: Text('รวม', style: TextStyle(fontWeight: FontWeight.bold))),
          Tab(child: Text('ยังไม่ถึง', style: TextStyle(fontWeight: FontWeight.bold))),
          Tab(child: Text('กำลังทำ', style: TextStyle(fontWeight: FontWeight.bold))),
          Tab(child: Text('สมบูรณ์', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget buildAppBar() {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(top: 15),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/todo_man2.png'), // ใส่ path ของรูปภาพใน assets
              fit: BoxFit.cover, // ปรับขนาดของรูปภาพให้เต็มพื้นที่
            ),
          ),
        ),
        Align(
  alignment: Alignment(-0.4, -0.3),
  child:
        Container(
          width: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(eventCount.toString(), 
                style: TextStyle(
                  fontSize: 80, 
                  color: Colors.white,  
                  fontWeight: FontWeight.bold, 
                  fontFamily: 'PixelFont', 
                  letterSpacing: 5.0
                ),
              ),
            ],
          )
        ),
        ),
        Positioned(
          top: 50,
          right: 12,
            child:  Container(
              height: 35,
              padding: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
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
              },
              borderColor: const Color.fromARGB(255, 147, 101, 37),
              selectedBorderColor: const Color.fromARGB(255, 73, 150, 123),
              borderWidth: 2,
              borderRadius: BorderRadius.circular(8.0),
              color: const Color.fromARGB(255, 109, 109, 109),
              fillColor: const Color.fromARGB(255, 98, 197, 162),
              constraints: BoxConstraints(
                minWidth: 35, // กำหนดความกว้างขั้นต่ำของปุ่ม
                minHeight: 35, // กำหนดความสูงขั้นต่ำของปุ่ม
              ),
              children: [
                Icon(Icons.view_list, size: 20, color: Colors.white),
                Icon(Icons.grid_view, size: 20, color: Colors.white),
              ],
            ),
          ),
        ),
      ],
    );
  }


  //buildBody

  // แสดง Dialog ให้ผู้ใช้เลือกประเภทกิจกรรม
  Future<String?> _showTypeSelectionDialog(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('ประเภทกิจกรรม', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: typeEvent
                  .map(
                    (type) => ListTile(
                      title: Text(type.name), // เปลี่ยนให้ตรงกับชื่อ field
                      onTap: () {
                        Navigator.of(context).pop(type.typeId);
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop('รีเซ็ต');
                  },
                  child: Text(
                    'รีเซ็ต',
                    style: TextStyle(color: const Color.fromARGB(255, 77, 169, 137), fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                CloseButton(color: const Color.fromARGB(255, 98, 197, 162)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildEventList(List<Event> events) {
    return viewMode == 1
      ? GridView.builder(
        padding: EdgeInsets.all(5.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, 
          mainAxisSpacing: 2.0,
          crossAxisSpacing: 2.0,
          childAspectRatio: 1 / 0.8, 
        ),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return _buildEventCard(event);
        },
      )
      : ListView.builder(
        padding: EdgeInsets.all(5.0),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return _buildEventCard(event);
        },
      );
  }


  Widget _buildEventCard(Event event) {
    return Card(
       shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10), // กำหนดความมนของขอบ
    ),
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      elevation: 3,
      color: Color(event.backgroundColor),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 8),
        title: viewMode == 0
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildEventTitle(title: event.title),
                  buildEventType(id: event.typeId),
                ],
              ),
              buildEventDescription(description: event.description),
            ],
        )
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                buildEventImage(imagePath: event.image),
                SizedBox(width: 10),
                buildEventTitle(title: event.title, length: 5),
              ],
            ),
            SizedBox(height: 10),
            Container(
              width: 150,
              height: 55,
              padding: EdgeInsets.all(3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildEventType(id: event.typeId),
                  buildEventDescription(description: event.description),
                ],
              ),
            ),
          ],
        ),
        leading: viewMode == 0
        ? buildEventImage(imagePath: event.image)
        : null,
        onTap: () async {
          final edit = await showDialog(
            context: context,
            builder: (context) => EventViewing(events: event),
          );
          if(edit == 'true' || edit == 'save') {
            setState(() {
              events = provider.events;
            });
          }
        },
      ),
    );
  }

  Widget buildEventImage({required String imagePath}) {
    return Container(
      width: 60,
      height: 60,
      child: Mfuntion.resolveImageWidget(imagePath: imagePath)
    );
  }

  Widget buildEventTitle({required String title, int length = 14}) {
    return Text(
      title.length > length ? title.substring(0, length) + '..' : title,
      style: TextStyle(
        color: const Color.fromARGB(255, 44, 44, 44),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget buildEventDescription({required String description}) {
    return Text(description != '' ? description : '...',
      style: TextStyle(color: const Color.fromARGB(255, 68, 68, 68)), 
      overflow: TextOverflow.ellipsis, 
      maxLines: 1
    );
  }

  Widget buildEventType({required String id}) {
    final type = provider.getTypeById(id);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 217, 217, 217),
        borderRadius: BorderRadius.circular(5)
      ),
      child: Text(type.name, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 110, 110, 110))),
    );
  }
  
}

