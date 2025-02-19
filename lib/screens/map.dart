import 'package:application_map_todolist/calendar/event_view.dart';
import 'package:application_map_todolist/storage/hive_storage.dart';
import 'package:application_map_todolist/units/mmfuntion.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:application_map_todolist/calendar/event_Editing.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:application_map_todolist/calendar/event_provider.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

class MyMap extends StatefulWidget {
  final int onNavigate;
  final String markerId;
  MyMap({super.key, required this.onNavigate, this.markerId = ''});
  @override
  State<MyMap> createState() => MyGoogleMap();
}

class MyGoogleMap extends State<MyMap> {
  late EventProvider provider;
  Position? userLocation ;
  late GoogleMapController Mapcontroller ;
  Completer<GoogleMapController> MapcontrollerCompleter = Completer();
  Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();
  List<LatLng> polylineCoordinates =[];
  Set<Polyline> polylines = {};
  LatLng? whereMarker ;
  String image = '';
  final List<String> imageList = [
    'assets/image_list/barber.png',
    'assets/image_list/business.png',
    'assets/image_list/cafe.png',
    'assets/image_list/camp.png',
    'assets/image_list/church.png',
    'assets/image_list/cinema.png',
    'assets/image_list/dentist.png',
    'assets/image_list/forest.png',
    'assets/image_list/gasstation.png',
    'assets/image_list/gym.png',
    'assets/image_list/helicopter.png',
    'assets/image_list/hospital.png',
    'assets/image_list/hospital.png',
    'assets/image_list/metrostation.png',
    'assets/image_list/music.png',
    'assets/image_list/office.png',
    'assets/image_list/policebadge.png',
    'assets/image_list/port.png',
    'assets/image_list/pub.png',
    'assets/image_list/resort.png',
    'assets/image_list/restaurant.png',
    'assets/image_list/shoppingcart.png',
    'assets/image_list/taxistop.png',
    'assets/image_list/theater.png',                                                                    
  ];

  @override
  void initState() {
    super.initState();
    provider = Provider.of<EventProvider>(context, listen: false);
    _loadMarkersOnMap();
  }

  Future<void> _deleteMarker(String markerId) async {
    provider.deleteMarker(markerId);
    setState(() {
      _markers.removeWhere((marker) => marker.markerId == MarkerId(markerId));
    });
  }

  void _loadMarkersOnMap() async {
    loadMarker(context);
    setState(() {
      whereMarker ;
    });
    if(widget.onNavigate == 2) {
      updateWhereMarker(widget.markerId);
    }
  }

  void loadMarker(BuildContext context) async {
  final markerList = await DataStorage().getMarkers();
  for (var markerData in markerList) {
      Position positionload = Position(
        latitude: markerData.lat,
        longitude: markerData.lng,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
        timestamp: DateTime(0),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
      );
      Marker marker = Marker(
        markerId: MarkerId(markerData.markerId),
        position: LatLng(markerData.lat, markerData.lng),
        icon: BitmapDescriptor.fromBytes(await getBytesFromPath(markerData.icon, 100)),
        infoWindow: InfoWindow(
          title: '🔴',
        ),
        onTap: () {
          onMenuMaker(context, markerData.markerId, positionload, 'Old');
        }
      );
      setState(() {
        _markers.add(marker);  
      });
  }
}


  void addCustomMarker(Position position, String markerId) async {
    final Uint8List markerIcon = await getBytesFromPath(image, 100);
    Marker marker = Marker(
      markerId: MarkerId(markerId),
      position: LatLng(position.latitude, position.longitude),
      icon: BitmapDescriptor.fromBytes(markerIcon),
      onTap: () {
        onMenuMaker(context, markerId, position, 'Old');
      }
    );
    setState(() {
      _markers.add(marker);
    });
    provider.addMarker(marker, image);
  }

  Future<Uint8List> getBytesFromPath(String path, int width) async {
    if (path.startsWith('assets/')) {
      ByteData data = await rootBundle.load(path);
      ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
      ui.FrameInfo fi = await codec.getNextFrame();
      return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
    } if (path.startsWith('data:image')) {
      final base64Data = path.split(',').last;
      final Uint8List bytes = base64Decode(base64Data);
      final ui.Codec codec = await ui.instantiateImageCodec(bytes, targetWidth: width);
      final ui.FrameInfo frame = await codec.getNextFrame();
      final ByteData? byteData = await frame.image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to convert image to ByteData');
      }
      return byteData.buffer.asUint8List();
    } else {
      throw Exception("File not found");
    }
  }


  // showImageSelector

  void showImageSelector(BuildContext context, Position position) {
    final int markerId = DateTime.now().millisecondsSinceEpoch % 100000000;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int selectedIndex = 0; // ตัวแปรสำหรับติดตามแท็บที่เลือก
        final tabController = PageController(initialPage: selectedIndex);
        return Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: 0.5, // สูงครึ่งจอ
            child: Material(
              color: Colors.white, // พื้นหลังสีขาว
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
              child:  StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Container(
                    height: 380,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: ToggleButtons(
                            isSelected: [selectedIndex == 0, selectedIndex == 1],
                            onPressed: (int index) {
                              setState(() {
                                selectedIndex = index;
                                tabController.jumpToPage(index);
                              });
                            },
                            borderRadius: BorderRadius.circular(8.0),
                            selectedColor: Colors.white,
                            color: const Color.fromARGB(255, 109, 109, 109),
                            fillColor: const Color.fromARGB(255, 98, 197, 162),
                            constraints: BoxConstraints(
                              minHeight: 30.0,
                              minWidth: 70.0,
                            ),
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.apps, size: 20), // ไอคอนรายการ
                                  Text('แอป', style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.people, size: 20), // ไอคอนกริด
                                  Text('ผู้ใช้', style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: PageView(
                            controller: tabController,
                            onPageChanged: (index) {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                            children: [
                              buildImageList(imageList, position, markerId.toString()),
                              buildImageList(provider.images, position, markerId.toString()),
                            ],
                          ),
                        ),
                        // ปุ่มยกเลิกและถัดไป
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CloseButton(
                              color: Color.fromARGB(255, 98, 197, 162), 
                              onPressed: () async {
                                await _deleteMarker(markerId.toString());
                                Navigator.pop(context);
                                _loadMarkersOnMap();
                              },
                            ),
                            IconButton(
                              onPressed: () async {
                                if (image == '') {
                                  // แก้ไข
                                } else {
                                  Navigator.pop(context);
                                  final isClose = await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => EventEditing(
                                        image: image,
                                        markerId: markerId.toString(),
                                      ),
                                    ),
                                  );
                                  if(isClose == 'close') {
                                    await _deleteMarker(markerId.toString());
                                    _loadMarkersOnMap();
                                  }
                                }
                                image = '';
                              },
                              icon: Icon(Icons.done, color: Color.fromARGB(255, 98, 197, 162), size: 30,),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildImageList(List<String> images, Position position, String markerId) {
    return  !images.isEmpty
    ? GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: images.length,
      itemBuilder: (BuildContext context, int index) {
        final imagePath = images[index];
        return  buildImageMarker(imagePath, markerId, position);
      },
    )
    : Center(
      child: Text('ไม่มีรูปภาพ เพิ่มรูปได้ในตั้งค่า'),
    );
  }

  Widget buildImageMarker(String imagePath,String markerId, Position position) {
    return GestureDetector(
      onTap: () {
        setState(() {
          image = imagePath;
          addCustomMarker(position, markerId);
        });
      },
      child: Container(
        padding: EdgeInsets.all(15.0),
        child: Mfuntion.resolveImageWidget(imagePath: imagePath)
      ),
    );
  }

  // END showImageSelector



  Future<Position?> getlocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if(permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
      userLocation = await Geolocator.getCurrentPosition(locationSettings: locationSettings,);
    } catch (e) {
      userLocation = null;
    }
    return userLocation;
  }

  void _onMapCreated(GoogleMapController controller) {
    Mapcontroller = controller ;
    MapcontrollerCompleter.complete(controller);
  }

 void _onTap(LatLng position) {
    final String markerId = '1';
    Position positionGO = Position(
      latitude: position.latitude,
      longitude: position.longitude,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
      timestamp: DateTime(0),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
    );
    setState(() {
      polylines.clear();
      _markers.add(
        Marker(
          markerId: MarkerId(markerId),
          position: LatLng(position.latitude, position.longitude),
            onTap: () {
              onMenuMaker(context, markerId, positionGO, 'New');
            },
        ),
      );
    });
  }

  Future<void> _getPolyline(Position endLocation) async {
    final String url =
      'https://maps.googleapis.com/maps/api/directions/json?origin=${userLocation!.latitude},${userLocation!.longitude}&destination=${endLocation.latitude},${endLocation.longitude}&key=AIzaSyDM_jiIQkI72-9w9APS5nDyT4WWKHzsq7E';
    final response =await http.get(Uri.parse(url));
    if(response.statusCode == 200) {
      final data = json.decode(response.body);
      if(data['routes'].isNotEmpty) {
        final route = data['routes'][0];
        final polyline = route['overview_polyline']['points'];
        final polylinePoints = PolylinePoints().decodePolyline(polyline);
        setState(() {
          polylineCoordinates = polylinePoints
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
          polylines.add(Polyline(
            polylineId: PolylineId('polyline'),
            color: Colors.blue,
            points: polylineCoordinates,
            ));
        });
      } else {
        print('ไม่มีเส้นทางในข้อมูล');
      }
    } else {
      throw Exception('รับข้อมูลผิดพลาด');
    }
  }

  void _searchPlace() async {
    try {
      List<Location> locations = await locationFromAddress(_searchController.text);
      if(locations.isNotEmpty) {
        final location = locations.first;
        setState(() {
          Mapcontroller.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(location.latitude, location.longitude), 18),
          );
        });
      } else{
        print('ไม่มีตำเเหน่งที่ค้นหา');
      }
    } catch (e) {
      print('ข้อผิดพลาด: $e');
    }
  }

  void onMenuMaker(BuildContext context,String markerId, Position position, String markerNewOrOld) {
    _markers.removeWhere((marker) => marker.markerId.value == '1');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          children: [
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              right: 0,
              left: 0,
              bottom: MediaQuery.of(context).size.height * 0.41,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  bottonOnMenuMaker(
                    onTap: () {
                      Navigator.pop(context);
                      _getPolyline(position);
                    },
                    icon: Icons.route_rounded,
                    color: const Color.fromARGB(255, 24, 74, 125),
                  ),
                  if(markerNewOrOld != 'New')
                  const SizedBox(width: 10),
                  if(markerNewOrOld != 'New')
                  bottonOnMenuMaker(
                    onTap: () async {
                      final event = await provider.getEventByMarkerId(markerId);
                      if(event != null) {
                        final delete = await Navigator.push(context, MaterialPageRoute(builder: (context) => EventViewing(events: event)));
                        if(delete == 'true') {
                          Navigator.pop(context);
                          _deleteMarker(markerId);
                          _loadMarkersOnMap();
                        }
                      }
                    },
                    icon: Icons.search,
                    color: const Color.fromARGB(255, 89, 173, 143),
                  ),
                  const SizedBox(width: 10),
                  bottonOnMenuMaker(
                    onTap: () async {
                      if (markerNewOrOld == 'New') {
                        Navigator.pop(context);
                        showImageSelector(context, position);
                      } else {
                        Navigator.pop(context);
                        provider.deleteEvent(markerId);
                         _deleteMarker(markerId);
                        _loadMarkersOnMap();
                      }
                    },
                    icon: markerNewOrOld == 'New'
                      ? Icons.add_location_alt
                      : Icons.delete,
                    color: markerNewOrOld == 'New'
                      ? const Color.fromARGB(255, 42, 137, 138)
                      : const Color.fromARGB(255, 152, 47, 40),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget bottonOnMenuMaker({required GestureTapCallback onTap, required Color color, required IconData icon}) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: color,
          ),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

    //  END Popup Menu //

   void _TrackingUser(Position? userLocation) async {
    await getlocation();
    if (userLocation != null) {
      Mapcontroller.animateCamera(
        CameraUpdate.newLatLng(LatLng(userLocation.latitude, userLocation.longitude)),
      );
    }
  }

  bool _isImageSelectorShown = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getlocation(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if(widget.onNavigate == 1) {
              if (!_isImageSelectorShown) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showImageSelector(context, userLocation!);
                  _isImageSelectorShown = true;
                });
              }
            }
            return Stack (
              children: <Widget>[
                GoogleMap(
                  mapType: MapType.terrain,
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  trafficEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(userLocation!.latitude, userLocation!.longitude),
                    zoom: 18,
                  ),
                  onMapCreated: _onMapCreated,
                  markers: _markers,
                  onTap: _onTap,
                  polylines: polylines,
                ),
                buildUserlocationButton(),
                buildSearchtab(),
              ],
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[CircularProgressIndicator()],
              ),
            );
          }
        }
      ),
    );
  }

  void updateWhereMarker(String id) {
    MapcontrollerCompleter.future.then((_) {
      try {
        final marker = _markers.firstWhere(
          (marker) => marker.markerId.value == id,
        );
        whereMarker = marker.position;
        moveToWhereMarker();
      } catch (e) {
        debugPrint('❌ เกิดข้อมผิดพลาดการหาตำแหน่งกิจกรรม : $e');
      }
    });
  }

  void moveToWhereMarker() {
    Future.delayed(Duration(milliseconds: 1000), () {
      if (whereMarker != null) {
        Mapcontroller.animateCamera(
          CameraUpdate.newLatLng(whereMarker!),
        );
      }
    });
  }

  Widget buildUserlocationButton() => Positioned(
    bottom: MediaQuery.of(context).size.height * 0.095,
    right: MediaQuery.of(context).size.height * 0.02,
    child: Container(
      child: FloatingActionButton(
        shape: CircleBorder(),
        backgroundColor: const Color.fromARGB(255, 36, 74, 114),
        onPressed: () { 
          _TrackingUser(userLocation);
        },
        child: Icon(
          Icons.my_location,
          color: Colors.white,
          size: 25,
        ),
      ),
    ),
  );

  Widget buildSearchtab() => Positioned(
    top: 40.0,
    left: 40.0,
    right: 40.0,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.pin_drop_sharp),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            }
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration:  InputDecoration(
                hintText: 'ค้นหาสถานที่...',
                suffixIcon: IconButton(
                icon:  Icon(Icons.search),
                onPressed: _searchPlace,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    ),
  );

}