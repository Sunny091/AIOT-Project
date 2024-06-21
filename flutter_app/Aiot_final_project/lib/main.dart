import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'tabBar.dart';

const OutlineInputBorder testfieldSet = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(20)),
  borderSide: BorderSide(
    width: 2,
    color: Color.fromARGB(255, 223, 223, 223),
  ),
);

const TextStyle kTitleTextStyle = TextStyle(
  fontSize: 50,
  color: Color.fromARGB(255, 255, 255, 255),
  fontWeight: FontWeight.w500,
);

const TextStyle kLittieTitleTextStyle = TextStyle(
  fontSize: 25,
  color: Color.fromARGB(255, 255, 255, 255),
  fontWeight: FontWeight.w400,
);

const TextStyle kBodyTextStyle = TextStyle(
  fontSize: 16,
  color: Color.fromARGB(255, 255, 255, 255),
  fontWeight: FontWeight.w400,
);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //await NotificationPlugin().init();
  //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        // appBar: AppBar(
        //   backgroundColor: Color.fromARGB(255, 117, 113, 173),
        //   // backgroundColor: Color.fromARGB(255, 43, 36, 129),
        //   // backgroundColor: Color.fromARGB(255, 237, 183, 142),
        //   //title: Text('登入'),
        // ),
        body: Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg4.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: HomePage()),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController controller_account = new TextEditingController();
  final TextEditingController controller_pwd = new TextEditingController();

  bool passwordVisible = true;

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      // Image.asset(
      //   'assets/images/logo_circle.png',
      //   width: 100,
      //   height: 100,
      // ),
      // const Padding(
      //   padding: EdgeInsets.all(10),
      // ),
      SizedBox(height: 80),
      const Text('智慧藥盒', style: kTitleTextStyle),
      Container(
        //color: const Color.fromARGB(255, 209, 209, 209),
        alignment: Alignment.center,
        margin: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 16),
            Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(
                          left: 0, top: 0, right: 0, bottom: 0),
                      padding: const EdgeInsets.only(
                          left: 25, top: 20, right: 25, bottom: 30),
                      decoration: BoxDecoration(
                        //裝飾內部布建用可定義容器形色
                        color: Color.fromRGBO(108, 75, 170, 0.498),
                        border: Border.all(
                            color: Color.fromARGB(255, 255, 255, 255), //設定邊框顏色
                            width: 2 //設定邊框寬度
                            ),
                        borderRadius: const BorderRadius.all(
                            const Radius.circular(20)), //設定圓角
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(255, 176, 176, 176)
                                .withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Column(children: <Widget>[
                        // SizedBox(height: 16),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                '- 注意事項 -',
                                style: kLittieTitleTextStyle,
                              ),
                              SizedBox(height: 20),
                              BulletPointText(text: '進入後請先設定您吃藥的資訊'),
                              BulletPointText(text: '送出資訊後即可將藥物放置於藥盒中'),
                              BulletPointText(text: '請記得從藥盒的第一格開始放最先要吃的藥'),
                              BulletPointText(text: '到吃藥時間時藥格會自動解鎖，LED燈也會亮起'),
                              BulletPointText(text: '當超出吃藥時間 15 分鐘後蜂鳴器便會鈴響'),
                              BulletPointText(
                                  text: '鈴響超過 15 分鐘即會停止鈴響並紀錄為"未準時吃藥"'),
                              BulletPointText(text: '在期間內吃藥了則會紀錄為"已吃藥"'),
                              BulletPointText(
                                  text: '如至下次吃藥時都未打開藥盒吃藥則會紀錄為"未吃藥"'),
                              BulletPointText(
                                  text: '吃藥期間如有緊急狀況可點擊"停止此次吃藥紀錄"按鈕以停止紀錄'),
                              // Text(
                              //     '歡迎使用智慧藥盒！\n以下有幾點注意事項：\n1. 進入後請先設定您吃藥的資訊\n2. 輸入後即可將藥物放置於藥盒中\n3. 請記得從藥盒的第一格開始放最先要吃的藥\n4. 當超出吃藥時間 15 分鐘後蜂鳴器便會鈴響\n5. 鈴響超過 15 分鐘即會停止鈴響並紀錄為未吃藥\n6. 吃藥期間如有緊急狀況可點選"停止吃藥"按鈕打開藥格並停止此次紀錄',
                              //     style: kBodyTextStyle)
                            ])
                      ])),
                  SizedBox(height: 60),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        //side: BorderSide(color: Colors.red, width: 1.0),
                      ),
                      minimumSize: Size(350, 50),
                      textStyle: (TextStyle(fontSize: 25)),
                      foregroundColor: Color.fromARGB(255, 255, 255, 255),
                      backgroundColor: Color.fromARGB(255, 237, 183, 142),
                      side: BorderSide(
                          color: Color.fromARGB(255, 218, 169, 131),
                          width: 0.5),
                    ),

                    // backgroundColor: Color.fromARGB(255, 241, 207, 142)),
                    child: const Text('開始'),
                    onPressed: () async {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Tabbar()));
                    },
                  ),
                ]),
          ],
        ),
      ),
    ]);
  }
}

class BulletPointText extends StatelessWidget {
  final String text;
  const BulletPointText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Text(
            '•  ',
            style: kBodyTextStyle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: kBodyTextStyle,
          ),
        ),
      ],
    );
  }
}
