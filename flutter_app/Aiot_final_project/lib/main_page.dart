import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:table_calendar/table_calendar.dart';

const TextStyle kTitleTextStyle = TextStyle(
  fontSize: 30,
  color: Color.fromARGB(255, 255, 255, 255),
  fontWeight: FontWeight.w500,
);

const TextStyle kLittieTitleTextStyle = TextStyle(
  fontSize: 20,
  height: 2.0,
  // backgroundColor: Color.fromARGB(255, 32, 71, 84),
  backgroundColor: Color.fromRGBO(172, 62, 110,
      0.475), // 185, 81, 77, 0.49 //245, 176, 116, 0.8 //186, 72, 68, 0.6
  color: Color.fromARGB(255, 255, 255, 255),
  fontWeight: FontWeight.w500,
);

const TextStyle kBodyTextStyle = TextStyle(
  fontSize: 20,
  color: Color.fromARGB(255, 255, 255, 255),
  fontWeight: FontWeight.w400,
);

final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
    // side: BorderSide(color: Colors.red, width: 1.0), // 如果需要边框可以取消注释
  ),
  // minimumSize: const Size(120, 40),
  fixedSize: const Size(129, 40),
  textStyle: TextStyle(fontSize: 16),
  foregroundColor: Color.fromARGB(255, 112, 51, 142),
  backgroundColor: Color.fromARGB(255, 255, 255, 255),
);

final ButtonStyle cancelButtonStyle = ElevatedButton.styleFrom(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
    // side: BorderSide(color: Colors.red, width: 1.0), // 如果需要边框可以取消注释
  ),
  minimumSize: const Size(70, 40),
  textStyle: TextStyle(fontSize: 16),
  foregroundColor: Color.fromARGB(255, 192, 66, 66),
  backgroundColor: Color.fromARGB(255, 255, 255, 255),
);

const OutlineInputBorder testfieldSet = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(15)),
  borderSide: BorderSide(
    width: 2,
    color: Color.fromARGB(255, 223, 223, 223),
  ),
);

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   backgroundColor: Color.fromARGB(255, 117, 113, 173),
      //   // backgroundColor: Color.fromARGB(255, 43, 36, 129),
      //   // backgroundColor: Color.fromARGB(255, 237, 183, 142),
      //   // title: Text('登入'),
      // ),
      body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg4.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: _MainPage()),
    );
  }
}

class _MainPage extends StatefulWidget {
  @override
  State<_MainPage> createState() => __MainPage();
}

class __MainPage extends State<_MainPage> {
  List<String> medicationRecords = []; // Medication records list

  TextEditingController medicationTimeController =
      TextEditingController(); // Controller for medication time input
  final TextEditingController controller_reason = new TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DateTime start_DateTime = DateTime.now();
  DateTime end_DateTime = DateTime.now();

  //TimeOfDay selectedTimeOfDay = TimeOfDay.now();
  String DateTime_breakfast = "請選擇時間";
  String DateTime_lunch = "請選擇時間";
  String DateTime_dinner = "請選擇時間";
  String DateTime_sleep = "請選擇時間";

  final List<String> period_items = [
    '短期吃藥',
    '長期吃藥',
  ];

  final List<String> medicine_type_items = [
    '一般藥品',
    '抗生素',
  ];

  String? medicine_type;
  String? period;

  String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Timestamp convertToTimestamp(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return Timestamp.fromDate(dateTime);
  }

  int? _getHour(String time) {
    return (time != '請選擇時間') ? int.parse(time.substring(0, 2)) : null;
  }

  int? _getMinute(String time) {
    return (time != '請選擇時間') ? int.parse(time.substring(3)) : null;
  }

  void _send_date_and_time() async {
    DocumentReference docRef = _firestore
        .collection('date_and_time_settings')
        .doc(DateFormat("yyyy-MM-dd").format(start_DateTime));

    await docRef.set({
      'start_year': FieldValue.arrayUnion([start_DateTime.year]),
      'start_month': FieldValue.arrayUnion([start_DateTime.month]),
      'start_date': FieldValue.arrayUnion([start_DateTime.day]),
      'end_year': FieldValue.arrayUnion([end_DateTime.year]),
      'end_month': FieldValue.arrayUnion([end_DateTime.month]),
      'end_date': FieldValue.arrayUnion([end_DateTime.day]),
      'breakfast_hour': FieldValue.arrayUnion([_getHour(DateTime_breakfast)]),
      'breakfast_minute':
          FieldValue.arrayUnion([_getMinute(DateTime_breakfast)]),
      'lunch_hour': FieldValue.arrayUnion([_getHour(DateTime_lunch)]),
      'lunch_minute': FieldValue.arrayUnion([_getMinute(DateTime_lunch)]),
      'dinner_hour': FieldValue.arrayUnion([_getHour(DateTime_dinner)]),
      'dinner_minute': FieldValue.arrayUnion([_getMinute(DateTime_dinner)]),
      'sleep_hour': FieldValue.arrayUnion([_getHour(DateTime_sleep)]),
      'sleep_minute': FieldValue.arrayUnion([_getMinute(DateTime_sleep)]),
    }, SetOptions(merge: true));
  }

  void _send_information() async {
    String reason = controller_reason.text;
    DocumentReference docRef = _firestore
        .collection('information')
        .doc(DateFormat("yyyy-MM-dd").format(start_DateTime));
    await docRef.set({
      'medicine_type': FieldValue.arrayUnion([medicine_type]),
      'reason': FieldValue.arrayUnion([reason]),
      'type': FieldValue.arrayUnion([period]),
    }, SetOptions(merge: true));
  }

  void _errorDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('⚠️錯誤'),
        content: const Text(
          '請至少選擇一個吃藥時間',
          style: TextStyle(fontSize: 20),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => {Navigator.pop(context, '關閉')},
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }

  void _comfirmDialog(BuildContext context) {
    // isShowDialog = true;
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('⚠️提醒'),
        content: const Text(
          '即將送出資訊，\n請確認資料無誤',
          style: TextStyle(fontSize: 20),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => {
              _send_date_and_time(),
              _send_information(),
              Navigator.pop(context, '確認')
            },
            child: const Text('確認'),
          ),
          TextButton(
            onPressed: () => {
              Navigator.pop(context, '取消'),
              // isShowDialog = false,
            },
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
        shrinkWrap: true,
        // padding: const EdgeInsets.all(20.0),
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Column(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(
                    left: 30, top: 0, right: 30, bottom: 10),
                padding: const EdgeInsets.only(
                    left: 20, top: 30, right: 20, bottom: 10),
                decoration: BoxDecoration(
                    //裝飾內部布建用可定義容器形色
                    color: Color.fromRGBO(108, 75, 170, 0.498),
                    border: Border.all(
                        color: Color.fromARGB(255, 233, 233, 233), //設定邊框顏色
                        width: 2 //設定邊框寬度
                        ),
                    borderRadius:
                        const BorderRadius.all(const Radius.circular(20)) //設定圓角
                    ),
                child: Column(
                  children: <Widget>[
                    // SizedBox(height: 16),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text('設定資訊', style: kTitleTextStyle),
                          const SizedBox(
                            height: 10,
                          ),
                          const Divider(
                            height: 2.0,
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text('― 吃藥類型 ―', style: kLittieTitleTextStyle),
                                SizedBox(width: 27),
                                Text('― 藥品類型 ―', style: kLittieTitleTextStyle),
                              ]),
                          SizedBox(height: 10),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                DropdownButtonHideUnderline(
                                  child: DropdownButton2<String>(
                                    isExpanded: true,
                                    hint: const Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '請選擇',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                              color: Color.fromARGB(
                                                  255, 112, 51, 142),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    items: period_items
                                        .map((String item) =>
                                            DropdownMenuItem<String>(
                                              value: item,
                                              child: Text(
                                                item,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.normal,
                                                  color: Color.fromARGB(
                                                      255, 112, 51, 142),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ))
                                        .toList(),
                                    value: period,
                                    onChanged: (value) {
                                      setState(() {
                                        period = value;
                                      });
                                    },
                                    buttonStyleData: ButtonStyleData(
                                      height: 50,
                                      width: 130,
                                      padding: const EdgeInsets.only(
                                          left: 14, right: 14),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.black26,
                                        ),
                                        color:
                                            Color.fromARGB(255, 237, 237, 237),
                                      ),
                                      elevation: 2,
                                    ),
                                    dropdownStyleData: DropdownStyleData(
                                      maxHeight: 200,
                                      width: 180,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        color:
                                            Color.fromARGB(255, 243, 243, 243),
                                      ),
                                      offset: const Offset(-20, 0),
                                      scrollbarTheme: ScrollbarThemeData(
                                        radius: const Radius.circular(40),
                                        thickness: MaterialStateProperty.all(6),
                                        thumbVisibility:
                                            MaterialStateProperty.all(true),
                                      ),
                                    ),
                                    menuItemStyleData: const MenuItemStyleData(
                                      height: 40,
                                      padding:
                                          EdgeInsets.only(left: 14, right: 14),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 18),
                                DropdownButtonHideUnderline(
                                  child: DropdownButton2<String>(
                                    isExpanded: true,
                                    hint: const Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '請選擇',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                              color: Color.fromARGB(
                                                  255, 112, 51, 142),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    items: medicine_type_items
                                        .map((String item) =>
                                            DropdownMenuItem<String>(
                                              value: item,
                                              child: Text(
                                                item,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.normal,
                                                  color: Color.fromARGB(
                                                      255, 112, 51, 142),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ))
                                        .toList(),
                                    value: medicine_type,
                                    onChanged: (value) {
                                      setState(() {
                                        medicine_type = value;
                                      });
                                    },
                                    buttonStyleData: ButtonStyleData(
                                      height: 50,
                                      width: 130,
                                      padding: const EdgeInsets.only(
                                          left: 14, right: 14),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.black26,
                                        ),
                                        color:
                                            Color.fromARGB(255, 237, 237, 237),
                                      ),
                                      elevation: 2,
                                    ),
                                    dropdownStyleData: DropdownStyleData(
                                      maxHeight: 200,
                                      width: 180,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        color:
                                            Color.fromARGB(255, 243, 243, 243),
                                      ),
                                      offset: const Offset(-20, 0),
                                      scrollbarTheme: ScrollbarThemeData(
                                        radius: const Radius.circular(40),
                                        thickness: MaterialStateProperty.all(6),
                                        thumbVisibility:
                                            MaterialStateProperty.all(true),
                                      ),
                                    ),
                                    menuItemStyleData: const MenuItemStyleData(
                                      height: 40,
                                      padding:
                                          EdgeInsets.only(left: 14, right: 14),
                                    ),
                                  ),
                                ),
                              ]),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text('― 吃藥原因 ―', style: kLittieTitleTextStyle),
                          const Padding(
                            padding: EdgeInsets.all(8),
                          ),
                          TextFormField(
                            controller: controller_reason,
                            decoration: const InputDecoration(
                              errorStyle: TextStyle(fontSize: 15),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              hintText: '請輸入吃藥原因(舉例：感冒、慢性病)',
                              contentPadding: const EdgeInsets.all(8),
                              // prefixIcon: Icon(Icons.person),
                              border: testfieldSet,
                              enabledBorder: testfieldSet,
                              focusedBorder: testfieldSet,
                              fillColor: Color.fromARGB(255, 255, 255, 255),
                              filled: true,
                            ),
                            //maxLength: 300,
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          const Text('設定時間(必填)', style: kTitleTextStyle),
                          const SizedBox(
                            height: 10,
                          ),
                          const Divider(
                            height: 2.0,
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text('― 開始日期 ―', style: kLittieTitleTextStyle),
                                SizedBox(width: 27),
                                Text('― 結束日期 ―', style: kLittieTitleTextStyle),
                              ]),
                          const SizedBox(height: 10),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                ElevatedButton(
                                  style: elevatedButtonStyle,
                                  onPressed: () async {
                                    var result = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2024, 05),
                                      lastDate: DateTime(2024, 12),
                                    );

                                    if (result != null) {
                                      setState(() {
                                        start_DateTime = result;
                                      });
                                    }
                                  },
                                  child: Text(DateFormat("yyyy-MM-dd")
                                      .format(start_DateTime)),
                                ),
                                // Text(formattedDate, style: kBodyTextStyle),
                                const Padding(
                                  padding: EdgeInsets.all(8),
                                ),
                                ElevatedButton(
                                  style: elevatedButtonStyle,
                                  onPressed: () async {
                                    var result = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2024, 05),
                                      lastDate: DateTime(2024, 12),
                                    );

                                    if (result != null) {
                                      setState(() {
                                        end_DateTime = result;
                                      });
                                    }
                                  },
                                  child: Text(DateFormat("yyyy-MM-dd")
                                      .format(end_DateTime)),
                                )
                              ]),
                          SizedBox(height: 20),
                          Text('― 吃藥時間 ―', style: kLittieTitleTextStyle),
                          SizedBox(height: 5),
                          Text('(只選擇需要吃藥的時間即可)', style: kBodyTextStyle),
                          const Padding(
                            padding: EdgeInsets.all(8),
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text('早上：', style: kBodyTextStyle),
                                ElevatedButton(
                                  // 早餐
                                  style: elevatedButtonStyle,
                                  onPressed: () async {
                                    var result = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                      builder: (context, child) {
                                        return MediaQuery(
                                          data: MediaQuery.of(context).copyWith(
                                              alwaysUse24HourFormat: true),
                                          child: child ?? Container(),
                                        );
                                      },
                                      initialEntryMode:
                                          TimePickerEntryMode.input,
                                    );

                                    if (result != null) {
                                      setState(() {
                                        //DateTime_breakfast = result;
                                        DateTime_breakfast =
                                            formatTimeOfDay(result);
                                        // formattedTimeOfDay = result.format(context);
                                      });
                                    }
                                  },
                                  child: Text(DateTime_breakfast),
                                ),
                                SizedBox(width: 18),
                                ElevatedButton(
                                  style: cancelButtonStyle,
                                  onPressed: () async {
                                    setState(() {
                                      DateTime_breakfast = '請選擇時間';
                                    });
                                  },
                                  child: Text('取消'),
                                )
                              ]),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text('中午：', style: kBodyTextStyle),
                                ElevatedButton(
                                  // 午餐
                                  style: elevatedButtonStyle,
                                  onPressed: () async {
                                    var result = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                      builder: (context, child) {
                                        return MediaQuery(
                                          data: MediaQuery.of(context).copyWith(
                                              alwaysUse24HourFormat: true),
                                          child: child ?? Container(),
                                        );
                                      },
                                      initialEntryMode:
                                          TimePickerEntryMode.input,
                                    );

                                    if (result != null) {
                                      setState(() {
                                        DateTime_lunch =
                                            formatTimeOfDay(result);
                                      });
                                    }
                                  },
                                  child: Text(DateTime_lunch),
                                ),
                                SizedBox(width: 18),
                                ElevatedButton(
                                  style: cancelButtonStyle,
                                  onPressed: () async {
                                    setState(() {
                                      DateTime_lunch = '請選擇時間';
                                    });
                                  },
                                  child: Text('取消'),
                                )
                              ]),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text('晚上：', style: kBodyTextStyle),
                                ElevatedButton(
                                  // 晚餐
                                  style: elevatedButtonStyle,
                                  onPressed: () async {
                                    var result = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                      builder: (context, child) {
                                        return MediaQuery(
                                          data: MediaQuery.of(context).copyWith(
                                              alwaysUse24HourFormat: true),
                                          child: child ?? Container(),
                                        );
                                      },
                                      initialEntryMode:
                                          TimePickerEntryMode.input,
                                    );

                                    if (result != null) {
                                      setState(() {
                                        DateTime_dinner =
                                            formatTimeOfDay(result);
                                      });
                                    }
                                  },
                                  child: Text(DateTime_dinner),
                                ),
                                SizedBox(width: 18),
                                ElevatedButton(
                                  style: cancelButtonStyle,
                                  onPressed: () async {
                                    setState(() {
                                      DateTime_dinner = '請選擇時間';
                                    });
                                  },
                                  child: Text('取消'),
                                )
                              ]),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text('睡前：', style: kBodyTextStyle),
                                ElevatedButton(
                                  // 睡前
                                  style: elevatedButtonStyle,
                                  onPressed: () async {
                                    var result = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                      builder: (context, child) {
                                        return MediaQuery(
                                          data: MediaQuery.of(context).copyWith(
                                              alwaysUse24HourFormat: true),
                                          child: child ?? Container(),
                                        );
                                      },
                                      initialEntryMode:
                                          TimePickerEntryMode.input,
                                    );

                                    if (result != null) {
                                      setState(() {
                                        DateTime_sleep =
                                            formatTimeOfDay(result);
                                      });
                                    }
                                  },
                                  child: Text(DateTime_sleep),
                                ),
                                SizedBox(width: 18),
                                ElevatedButton(
                                  style: cancelButtonStyle,
                                  onPressed: () async {
                                    setState(() {
                                      DateTime_sleep = '請選擇時間';
                                    });
                                  },
                                  child: Text('取消'),
                                )
                              ]),
                          // Text(formattedTimeOfDay, style: kBodyTextStyle),
                          const Padding(
                            padding: EdgeInsets.all(8),
                          ),
                        ]),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    //side: BorderSide(color: Colors.red, width: 1.0),
                  ),
                  minimumSize: Size(330, 50),
                  textStyle: (TextStyle(fontSize: 25)),
                  foregroundColor: Color.fromARGB(255, 255, 255, 255),
                  backgroundColor: Color.fromARGB(255, 237, 183, 142),
                  side: BorderSide(
                      color: Color.fromARGB(255, 218, 169, 131), width: 0.5),
                ),
                child: const Text('確認並送出'),
                onPressed: () async {
                  if (DateTime_breakfast == '請選擇時間' &&
                      DateTime_lunch == '請選擇時間' &&
                      DateTime_dinner == '請選擇時間' &&
                      DateTime_sleep == '請選擇時間') {
                    _errorDialog(context);
                  } else {
                    _comfirmDialog(context);
                  }
                },
              ),
              const Padding(
                padding: EdgeInsets.all(16),
              ),
            ],
          )
        ]);
  }
}
