import 'package:flutter/material.dart';

class Tutorial extends StatefulWidget {
  @override
  _TutorialState createState() => _TutorialState();
}

class _TutorialState extends State<Tutorial> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _pages = [
    'assets/image_tutorial/Slide0.jpg',
    'assets/image_tutorial/Slide1.JPG',
    'assets/image_tutorial/Slide2.JPG',
    'assets/image_tutorial/Slide3.JPG',
    'assets/image_tutorial/Slide4.JPG',
    'assets/image_tutorial/Slide5.JPG',
    'assets/image_tutorial/Slide6.JPG',
    'assets/image_tutorial/Slide7.JPG',
    'assets/image_tutorial/Slide8.JPG',
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // แสดงรูปภาพเต็มพื้นที่
        PageView.builder(
          controller: _pageController,
          itemCount: _pages.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(16), // ทำให้ขอบมน
              child: Image.asset(
                _pages[index],
                fit: BoxFit.cover, // ทำให้รูปภาพเต็มพื้นที่
              ),
            );
          },
        ),
        // ปุ่มเลื่อนไปหน้าถัดไปและปิด
        Positioned(
          bottom: 15,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _currentPage > 0
                    ? () {
                        _pageController.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      }
                    : () {
                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor:  _currentPage == 0 ? const Color.fromARGB(255, 98, 197, 162) : Colors.black54, // สีพื้นหลังโปร่งแสง
                  foregroundColor: Colors.white, // สีตัวอักษร
                ),
                child: Text( _currentPage == 0 ? 'เริ่มการใช้งาน' : 'ย้อนกลับ', style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              ElevatedButton(
                onPressed: _currentPage < _pages.length - 1
                    ? () {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      }
                    : () {
                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentPage == _pages.length - 1 ? const Color.fromARGB(255, 98, 197, 162) : Colors.black54,
                  foregroundColor: Colors.white,
                ),
                child: Text( _currentPage == _pages.length - 1 ? 'เริ่มการใช้งาน' : 'ถัดไป', style: TextStyle(fontWeight: FontWeight.bold),),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
