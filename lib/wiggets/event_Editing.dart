import 'package:flutter/foundation.dart' ;
import 'package:flutter/material.dart' ;
import 'package:flutter/widgets.dart' ;
import 'package:application_map_todolist/providers/event_provider.dart';
import 'package:provider/provider.dart';
import 'package:application_map_todolist/models/event_model.dart';
import 'package:application_map_todolist/models/type_model.dart';
import '../units/utils.dart' ;

class EventEditing extends StatefulWidget {
  const EventEditing({super.key, this.event, required this.image, required this.markerId});
  final Event? event;
  final String image;
  final String markerId;
  @override
  State<EventEditing> createState() => _EventEditingState() ;
}

class _EventEditingState extends State<EventEditing> {
  late EventProvider provider;
  final _formKey = GlobalKey<FormState>() ;
  final titleController = TextEditingController();
  late TextEditingController _descriptionController; 
  late String type;
  late DateTime fromDate ;
  late DateTime toDate ;
  late Color colorEvent = const Color.fromARGB(255, 165, 229, 217) ;

  bool notiStart = true;
  bool notiEnd = false;

  List<Type> typeEvent = [];

  Type? selectedType ;


  @override
  void initState()  {
    super.initState() ;
    _descriptionController = TextEditingController(
        text: widget.event?.description ?? '',
      );
    if (widget.event == null) {
      fromDate = DateTime.now() ;
      toDate = DateTime.now().add(Duration(hours : 1)) ;
    } else {
      final event = widget.event!;
      titleController.text = event.title ;
      fromDate = event.from ;
      toDate = event.to ;
      notiStart = event.notiStart;
      notiEnd = event.notiEnd;
      _descriptionController = TextEditingController(text: widget.event?.description ?? '');
      colorEvent = Color(event.backgroundColor);
      final provided =Provider.of<EventProvider>(context, listen: false);
      selectedType = provided.getTypeById(widget.event!.typeId);
    }
  }

  @override
  void dispose(){
    titleController.dispose() ;
    _descriptionController.dispose();
    super.dispose() ;
  }

  void loadtypes() async {
    final typeEvents = provider.types;
    setState(() {
      typeEvent = [
        Type(typeId: '0', name: 'ทั่วไป', duration: ''),
        ...typeEvents,
      ];
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(
          color: Color.fromARGB(255, 98, 197, 162),
          onPressed: () {
            Navigator.of(context).pop('close');
          }
        ),
        actions: buildEditingActions(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child : Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget> [
            buildTitle(),
            SizedBox(height: 12,),
            buildDescriotion(),
            SizedBox(height: 16),
            buildActivityTypeButton(context),
            SizedBox(height: 16),
            buildDateTimePickers(),
            SizedBox(height: 16),
            buildColorPicker(),
          ],
         ),
       ),
      ),
    );
  }

  List<Widget> buildEditingActions() => [
    IconButton(
      onPressed: saveFrom,
      icon: Icon(Icons.done, color: Color.fromARGB(255, 98, 197, 162), size: 30,),
      ),
  ] ;

  
  Widget buildTitle() => TextFormField(
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  decoration: InputDecoration(
    filled: true, // เติมสีพื้นหลังในช่องกรอก
    fillColor: Colors.white, // สีพื้นหลังของช่องกรอก
    hintText: 'ชื่อ',
    border: OutlineInputBorder( // ใช้ OutlineInputBorder เพื่อให้มีกรอบล้อมรอบ
      borderRadius: BorderRadius.circular(12), // กำหนดให้กรอบมน
      borderSide: BorderSide.none, // ไม่มีขีดเส้นที่กรอก
    ),
  ),
    onFieldSubmitted: (_) => saveFrom(),
    validator: (title) => 
      title != null && title.isEmpty ? 'Title cannot be empty' : null,
    controller: titleController,
  );


  Widget buildDescriotion() => TextFormField(
    style: TextStyle(fontSize: 17),
    controller: _descriptionController,
    decoration: InputDecoration(
      filled: true, // เติมสีพื้นหลังในช่องกรอก
      fillColor: Colors.white, // สีพื้นหลังของช่องกรอก
      hintText: 'เพิ่มเติม...',
      border: OutlineInputBorder( // ใช้ OutlineInputBorder เพื่อให้มีกรอบล้อมรอบ
        borderRadius: BorderRadius.circular(12), // กำหนดให้กรอบมน
        borderSide: BorderSide.none, // ไม่มีขีดเส้นที่กรอก
      ),
    ),
    maxLines: null, // สามารถพิมพ์ได้หลายบรรทัด
  );

  Widget buildDateTimePickers() => Container(
    padding: EdgeInsets.only(left: 16, top: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12)
    ),
    child: 
  Column(
    children: [
      Row(
        children: [
          Icon(Icons.timer, color: const Color.fromARGB(255, 98, 197, 162), size: 30,),
          SizedBox(width: 15,),
          Text('ช่วงเวลา', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('เริ่ม', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(
            flex: 2,
              child : buildDropdownField(
              text: Utils.toDate(fromDate),
              onClicked: () => pickFromDateTime(pickDate: true ), 
            ),
          ),
          Expanded(
              child : buildDropdownField(
              text: Utils.toTime(fromDate),
              onClicked: () => pickFromDateTime(pickDate: false), 
            ),
          ),
        ],
      ),
      Row(
          children: [
            Text('ถึง ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Expanded(
              flex: 2,
              child: buildDropdownField(
                text: Utils.toDate(toDate),
                onClicked: () => pickToDateTime(pickDate: true),
              ),
            ),
            Expanded(
              child: buildDropdownField(
                text: Utils.toTime(toDate),
                onClicked: () => pickToDateTime(pickDate: false),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 1,
              child:  Switch(
                activeColor: const Color.fromARGB(255, 98, 197, 162),
                value: notiStart,
                onChanged: (bool value) {
                  setState(() {
                    notiStart = value;
                  });
                },
              ),
            ),
            Expanded(
              flex: 1,
              child:  Switch(
                activeColor: const Color.fromARGB(255, 98, 197, 162),
                value: notiEnd,
                onChanged: (bool value) {
                  setState(() {
                    notiEnd = value;
                  });
                },
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Spacer(flex: 1),
            Text('เตือนเมื่อเริ่ม', style: TextStyle(color: const Color.fromARGB(255, 134, 134, 134))),
            Spacer(flex: 2),
            Text('เตือนเมื่อสิ้นสุด', style: TextStyle(color: const Color.fromARGB(255, 134, 134, 134))),
            Spacer(flex: 1),
          ],
        )
      ],
    ),
  );


  Future pickFromDateTime ({ required bool pickDate }) async {
  final date = await pickDateTime(fromDate , pickDate : pickDate) ; 
    if (date == null) return ;
    if (date.isAfter(toDate)) {
      toDate = DateTime(date.year , date.month , date.day , toDate.hour , toDate.minute) ;
    } 

    setState(() => fromDate = date ) ;

  }

  Future pickToDateTime ({ required bool pickDate }) async {
    final date = await pickDateTime(
      toDate , 
      pickDate : pickDate,
      firstDate: pickDate? fromDate: null) ; 

    if (date == null) return ;
    setState(() => toDate = date ) ;
 }

  Widget buildDropdownField ({
    required String text,
    required VoidCallback onClicked,
  }) => ListTile(
    title: Text(text),
    onTap: onClicked,
  );
    
 Future <DateTime?> pickDateTime (
  DateTime initialDate, {
    required bool pickDate,
    DateTime? firstDate ,
  }) async {
    if (pickDate){
      final date = await showDatePicker(
        context: context, 
        initialDate: initialDate,
        firstDate: firstDate?? DateTime(2018 , 8), 
        lastDate: DateTime(2101),
        );
        if ( date == null ) return null ; 
        
        final time = Duration(
          hours: initialDate.hour , minutes: initialDate.minute );

        return date.add(time) ;
    }else{
      final timeOfDay = await showTimePicker(
        context: context, 
        initialTime: TimeOfDay.fromDateTime(initialDate) , 
        );
        if(timeOfDay == null) return null ;
        final date = DateTime(initialDate.year, initialDate.month, initialDate.day);
        final time = Duration(hours: timeOfDay.hour , minutes: timeOfDay.minute);

        return date.add(time) ;
    }
  }
    
  Future<void> saveFrom() async {
    final isValid = _formKey.currentState!.validate();
    if(isValid) {
      final event = Event(
        id: widget.markerId,
        title: titleController.text,
        description: _descriptionController.text,
        from: fromDate,
        to: toDate,
        notiStart: notiStart,
        notiEnd: notiEnd,
        backgroundColor: colorEvent.value,
        image: widget.image,
        markerId: widget.markerId,
        typeId: selectedType == null ? '0' : selectedType!.typeId,
      );
      provider.addEvent(event);
      Navigator.of(context).pop('save');
    }
 }


 //////////////////////////////////////////////////////////////////
 ///


List<String> timeTypes = [
  '1 วัน',
  '3 วัน',
  '1 สัปดาห์',
  '2 สัปดาห์',
  '3 สัปดาห์',
  '1 เดือน',
  '2 เดือน',
  '3 เดือน',
  '4 เดือน',
  '5 เดือน',
  '6 เดือน',
  '7 เดือน',
  '8 เดือน',
  '9 เดือน',
  '10 เดือน',
  '11 เดือน',
  '1 ปี',
];

Widget buildActivityTypeButton(BuildContext context) {
  provider = Provider.of<EventProvider>(context);
  loadtypes();
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Container(
              height: 55,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: GestureDetector(
                onTap: () => _showTypeEventDialog(context), // กดแล้วเปิด Dialog
                child: Row(
                  children: [
                    Text(selectedType?.name ?? 'ประเภท: ทั่วไป', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 20),
                    Text(selectedType?.duration ?? '', style: TextStyle(fontSize: 15, color: const Color.fromARGB(255, 87, 87, 87))),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Container(
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color.fromARGB(255, 98, 197, 162),
            ),
            child: IconButton(
              onPressed: () => _showTypeEventDialog(context),
              icon: Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    ],
  );
}

void _confirmDelete(Type type) {
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
        content: Text('กิจกกรมทั้งหมดที่เป็น ประเภท: ${type.name} จะถูกลบ', style: TextStyle(fontSize: 16),),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.close, color: const Color.fromARGB(255, 98, 197, 162)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              IconButton(
                icon: Icon(Icons.done, color: const Color.fromARGB(255, 98, 197, 162)),
                onPressed: () async {
                  await provider.deleteType(type.typeId);
                  if(selectedType != type){
                    setState(() {
                      typeEvent.remove(type);
                    });
                  } else {
                    Navigator.of(context).pop();
                  }
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

void _showTypeEventDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 90),
            const Text(
              'ประเภท',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(width: 50),
            Container(
              height: 33,
              width: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(255, 98, 197, 162),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                  showAddActivityTypeDialog(context);
                },
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite, // ให้ขยายความกว้างเท่าที่เป็นไปได้
          height: 300, // กำหนดความสูงให้พอเหมาะ สามารถเปลี่ยนค่าตามต้องการ
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: typeEvent.map((type) {
                return ListTile(
                  title: Text(type.name),
                  subtitle: (type.name != 'ทั่วไป')
                      ? Text(type.duration, style: const TextStyle(color: Colors.grey))
                      : null,
                  trailing: (type.name != 'ทั่วไป')
                      ? Row(
                        mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: const Color.fromARGB(255, 98, 197, 162),),
                              onPressed: () {
                                Navigator.pop(context); // ปิด Dialog
                                showAddActivityTypeDialog(context, type: type);
                              }
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                Navigator.pop(context); // ปิด Dialog
                                _confirmDelete(type); // เรียกฟังก์ชันลบ
                              },
                            )
                          ],
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      selectedType = type;
                      toDate = addDuration(DateTime.now(), selectedType!.duration);
                    });
                    Navigator.of(context).pop(); // ปิด Dialog หลังจากเลือก
                  },
                );
              }).toList(),
            ),
          ),
        ),
      );
    },
  );
}



DateTime addDuration(DateTime date, String duration) {
  switch (duration) {
    case '1 วัน':
      return date.add(Duration(days: 1));
    case '3 วัน':
      return date.add(Duration(days: 3));
    case '1 สัปดาห์':
      return date.add(Duration(days: 7));
    case '2 สัปดาห์':
      return date.add(Duration(days: 14));
    case '3 สัปดาห์':
      return date.add(Duration(days: 21));
    case '1 เดือน':
      return DateTime(date.year, date.month + 1, date.day);
    case '2 เดือน':
      return DateTime(date.year, date.month + 2, date.day);
    case '3 เดือน':
      return DateTime(date.year, date.month + 3, date.day);
    case '4 เดือน':
      return DateTime(date.year, date.month + 4, date.day);
    case '5 เดือน':
      return DateTime(date.year, date.month + 5, date.day);
    case '6 เดือน':
      return DateTime(date.year, date.month + 6, date.day);
    case '7 เดือน':
      return DateTime(date.year, date.month + 7, date.day);
    case '8 เดือน':
      return DateTime(date.year, date.month + 8, date.day);
    case '9 เดือน':
      return DateTime(date.year, date.month + 9, date.day);
    case '1 0เดือน':
      return DateTime(date.year, date.month + 10, date.day);
    case '11 เดือน':
      return DateTime(date.year, date.month + 11, date.day);
    case '1 ปี':
      return DateTime(date.year + 1, date.month, date.day);
    default:
      return fromDate.add(Duration(hours : 1)); // ถ้า duration ไม่ตรง ให้คืนค่าเดิม
  }
}


void showAddActivityTypeDialog(BuildContext context, {Type? type}) {
  final int typeId = DateTime.now().millisecondsSinceEpoch % 100000000;
  final nameController = TextEditingController();
  final typeName = type?.name;
  if (selectedType != null && typeName != null) {
    nameController.text = typeName.trim();
  }

  String? selectedDuration  = type?.duration;
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: 400,
          minHeight: 280,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              type == null ? 'สร้างประเภทกิจกรรม' : 'แก้ไขประเภทกิจกรรม',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
              filled: true, // เติมสีพื้นหลังในช่องกรอก
              fillColor: Colors.white, // สีพื้นหลังของช่องกรอก
              hintText: type == null ? 'ชื่อ' : 'ชื่อใหม่',
              border: OutlineInputBorder( // ใช้ OutlineInputBorder เพื่อให้มีกรอบล้อมรอบ
                borderRadius: BorderRadius.circular(12), // กำหนดให้กรอบมน
                borderSide: BorderSide.none, // ไม่มีขีดเส้นที่กรอก
              ),
            ),
              controller: nameController,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                filled: true, // เติมสีพื้นหลังในช่องกรอก
                fillColor: Colors.white, // สีพื้นหลังของช่องกรอก
                hintText: 'ระยะเวลา',
                border: OutlineInputBorder( // ใช้ OutlineInputBorder เพื่อให้มีกรอบล้อมรอบ
                  borderRadius: BorderRadius.circular(12), // กำหนดให้กรอบมน
                  borderSide: BorderSide.none, // ไม่มีขีดเส้นที่กรอก
                ),
              ),
              items: timeTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              value: selectedDuration,
              onChanged: (value) {
                selectedDuration = value;
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CloseButton(
                  color: const Color.fromARGB(255, 98, 197, 162),
                ),
                IconButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty && selectedDuration != null) {
                      final newType =  Type(
                        typeId: type == null ? typeId.toString() : type.typeId,
                        name: name, 
                        duration: selectedDuration!
                      );
                      final newDuration = addDuration(DateTime.now(), newType.duration);
                      provider.addType(newType);
                      if(selectedType?.typeId == newType.typeId){
                        setState(() {
                          selectedType = newType;
                          toDate = newDuration;
                        });
                        List<Event> updatedEvents = provider.events.map((event) {
                          if (event.typeId == newType.typeId) {
                            return  Event(
                              id: event.id,
                              title: event.title,
                              description: event.description,
                              from: event.from,
                              to: newDuration,
                              notiStart: event.notiStart,
                              notiEnd: event.notiEnd,
                              backgroundColor: event.backgroundColor,
                              image: event.image,
                              markerId: event.markerId,
                              typeId: event.typeId,
                            );
                          }
                          return event;
                        }).toList();

                        // บันทึกค่าใหม่เข้า Provider
                        for (var event in updatedEvents) {
                          provider.addEvent(event);
                        }
                      }
                      loadtypes();
                      Navigator.pop(context);
                    }
                  },
                  icon: Icon(Icons.done, color: const Color.fromARGB(255, 98, 197, 162)),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

////////////////////////////////////////// color
  Widget buildColorPicker() => Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.color_lens, color:  const Color.fromARGB(255, 98, 197, 162), size: 30),
                SizedBox(width: 15,),
                Text('เลือกสี', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildColorOption(const Color.fromARGB(255, 165, 229, 217)),
                buildColorOption(const Color.fromARGB(255, 237, 193, 220)),
                buildColorOption(const Color.fromARGB(255, 183, 231, 178)),
                buildColorOption(const Color.fromARGB(255, 154, 189, 231)),
                buildColorOption(const Color.fromARGB(255, 185, 167, 224)),
                buildColorOption(const Color.fromARGB(255, 237, 165, 178)),
                buildColorOption(const Color.fromARGB(255, 235, 191, 161)),
              ],
            ),
          ],
        ),
      );

  // สร้าง Widget ตัวเลือกสี
  Widget buildColorOption(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          colorEvent = color;
        });
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: color == colorEvent
              ? Border.all(color: const Color.fromARGB(255, 75, 129, 111), width: 2)
              : null,
        ),
      ),
    );
  }


}