import 'package:flutter/material.dart';
import 'medication_calendar.dart';
import 'main_page.dart';

class Tabbar extends StatelessWidget {
  @override
  final List<Tab> myTabs = <Tab>[
    Tab(text: '輸入資訊'),
    Tab(text: '統計'),
  ];

  final pages = [MainPage(), MedicineTimeRecorder()];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: myTabs.length, //選項卡頁數
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 62, 58, 121),
            title: TabBar(
              indicatorColor: Color.fromARGB(255, 255, 255, 255),
              labelColor: Color.fromARGB(255, 255, 255, 255),
              labelStyle: TextStyle(fontSize: 22.0, fontFamily: 'Family Name'),
              //For Selected tab
              unselectedLabelStyle: TextStyle(
                fontSize: 18.0,
                color: Color.fromARGB(255, 190, 190, 190),
                fontFamily: 'Family Name',
              ), //For Un-selected Tab
              tabs: myTabs,
            ),
          ),
          body: TabBarView(
            children: <Widget>[MainPage(), MedicineTimeRecorder()],
          ),
        ),
      ),
    );
  }
}
