import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class MedicineTimeRecorder extends StatefulWidget {
  @override
  _MedicineTimeRecorderState createState() => _MedicineTimeRecorderState();
}

class _MedicineTimeRecorderState extends State<MedicineTimeRecorder> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  Stream<DocumentSnapshot> _getDayMedicineTimes(DateTime day) {
    final String selectedDate = day.toString().split(' ')[0];
    return _firestore.collection('record').doc(selectedDate).snapshots();
  }

  Stream<DocumentSnapshot> _getDateSettings(DateTime day) {
    final String selectedDate = day.toString().split(' ')[0];
    return _firestore
        .collection('date_and_time_settings')
        .doc(selectedDate)
        .snapshots();
  }

  Color _getMedicineStatus(int? state) {
    if (state == 0) {
      return Colors.green;
    } else if (state == 1) {
      return Colors.yellow;
    } else if (state == 2) {
      return Colors.red;
    } else {
      return Colors.transparent;
    }
  }

  String _getMedicineStateDescription(int? state) {
    if (state == 0) {
      return "(準時吃藥)";
    } else if (state == 1) {
      return "(未準時吃藥)";
    } else if (state == 2) {
      return "(未吃藥)";
    } else {
      return "";
    }
  }

  void _showDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('⚠️提醒'),
        content: const Text(
          '確定要停止本次吃藥紀錄嗎？',
          style: TextStyle(fontSize: 20),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, '確認');
            },
            child: const Text('確認'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, '取消');
            },
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              minimumSize: Size(250, 50),
              textStyle: TextStyle(fontSize: 20),
              foregroundColor: Colors.white,
              backgroundColor: Color.fromARGB(255, 237, 183, 142),
            ),
            onPressed: () {
              _showDialog(context);
            },
            child: const Text('停止此次吃藥紀錄'),
          ),
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                return StreamBuilder<DocumentSnapshot>(
                  stream: _getDayMedicineTimes(date),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var data = snapshot.data?.data() as Map<String, dynamic>?;
                      if (data != null) {
                        return Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: EdgeInsets.symmetric(horizontal: 1.5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    _getMedicineStatus(data['breakfast_state']),
                              ),
                            ),
                            Container(
                              width: 6,
                              height: 6,
                              margin: EdgeInsets.symmetric(horizontal: 1.5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getMedicineStatus(data['dinner_state']),
                              ),
                            ),
                          ],
                        );
                      }
                    }
                    return Container();
                  },
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: _getDayMedicineTimes(_selectedDay),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var data = snapshot.data?.data() as Map<String, dynamic>?;
                if (data == null) {
                  return Center(child: Text('今天還沒有記錄'));
                }

                return StreamBuilder<DocumentSnapshot>(
                  stream: _getDateSettings(_selectedDay),
                  builder: (context, dateSnapshot) {
                    if (!dateSnapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    var dateData =
                        dateSnapshot.data?.data() as Map<String, dynamic>?;

                    List<String> medicineTimes = [];
                    if (data['breakfast_hour'] != null &&
                        data['breakfast_minute'] != null) {
                      medicineTimes.add(
                        '早餐時間: ${data['breakfast_hour']}:${data['breakfast_minute']} ${_getMedicineStateDescription(data['breakfast_state'])}',
                      );
                    }
                    if (data['dinner_hour'] != null &&
                        data['dinner_minute'] != null) {
                      medicineTimes.add(
                        '晚餐時間: ${data['dinner_hour']}:${data['dinner_minute']} ${_getMedicineStateDescription(data['dinner_state'])}',
                      );
                    }
                    if (dateData != null &&
                        dateData['start_date'] != null &&
                        dateData['start_month'] != null &&
                        dateData['end_date'] != null &&
                        dateData['end_month'] != null) {
                      int startDate = dateData['start_date'][0];
                      int startMonth = dateData['start_month'][0];
                      int endDate = dateData['end_date'][0];
                      int endMonth = dateData['end_month'][0];

                      medicineTimes.add(
                        '吃藥開始日期: $startMonth/$startDate',
                      );
                      medicineTimes.add(
                        '吃藥結束日期: $endMonth/$endDate',
                      );
                    }

                    return ListView.builder(
                      itemCount: medicineTimes.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(medicineTimes[index]),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
