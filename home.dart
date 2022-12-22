import 'package:flutter/material.dart';
import 'package:my_topic_project/login.dart';
import 'package:my_topic_project/JumpPage.dart';
import 'package:mysql1/mysql1.dart';
import 'package:my_topic_project/ConnectMysql.dart';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:my_topic_project/MysqlList.dart';

class MainPage extends StatefulWidget {
  List<AllPagesNeedData> DataMenu = [];

  MainPage(this.DataMenu);

  @override
  _MainPageState createState() => _MainPageState();
}

//建構全畫面
class _MainPageState extends State<MainPage> {
  int currentIndex = 0;
  List<MysqlDataOfPersonal> PersonalMenu = []; //個人資料
  List<AllPagesNeedData> DataMenu = []; //頁面所需資料
  late List<Widget> pages = [
    HomePage(DataMenu),
    RecordPage(DataMenu),
    NewMessagePage(DataMenu),
    AboutUsPage(DataMenu),
  ];

  var db = new Mysql();
  String personal_name = "";

  @override
  void initState() {
    DataMenu = widget.DataMenu;
    _getMysqlData();
    _delayText();
    PrintList("MainPage", "AllPagesNeedData", DataMenu);
    super.initState();
  }

  //延遲取得資料庫資料，因為會有非同步的情況
  Future _delayText() async{
    Future.delayed(const Duration(milliseconds:500), () {
      setState(() {
        personal_name = PersonalMenu[0].name.toString();
      });
    });
  }

  //取得Mysql裡patient_database資料表的資料
  _getMysqlData() {
    PersonalMenu.clear(); //初始化列表
    db.getConnection().then((conn) {
      String sql =
          "SELECT * FROM patient_database WHERE id='${DataMenu[0].id}'";
      conn.query(sql).then((results) {
        print("連線成功!");
        for (var row in results) {
          // print(row);
          setState(() {
            PersonalMenu.add(
                MysqlDataOfPersonal(row['id'], row['name'], row['gender']));
          });
        }
      });
      conn.close();
    });
  }

  //在主畫面按下返回鍵
  Future<bool> RequestPop() async {
    //登出提示框
    showAlertDialog(context);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    final DrawerClassPage _drawer = DrawerClassPage(personal_name, DataMenu);

    //返回鍵
    return WillPopScope(
      onWillPop: RequestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          centerTitle: true,
          title: const Text(
            "失語症復健APP",
            style: TextStyle(fontSize: 25),
          ),
        ),
        drawer: _drawer,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.black87,
          //
          selectedFontSize: 20,
          unselectedFontSize: 18,
          iconSize: 30,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          selectedIconTheme: const IconThemeData(
            size: 42,
          ),
          unselectedIconTheme: const IconThemeData(
            size: 32,
          ),
          currentIndex: currentIndex,
          onTap: (int idx) {
            setState(() {
              currentIndex = idx;
              PrintList(
                  pages[currentIndex].toString(), "AllPagesNeedData", DataMenu);
            });
          },
          items: [
            buildBottomNavigationBarView(
                Icons.home, Colors.redAccent.shade400, "首頁", DataMenu),
            buildBottomNavigationBarView(Icons.schedule_outlined,
                Colors.yellow.shade400, "紀錄", DataMenu),
            buildBottomNavigationBarView(Icons.circle_notifications_rounded,
                Colors.lightGreen.shade400, "訊息", DataMenu),
            buildBottomNavigationBarView(
                Icons.error_rounded, Colors.blue.shade300, "關於", DataMenu),
          ],
        ),
        body: pages[currentIndex],
      ),
    );
  }
}

// 首頁，主要頁面
class HomePage extends StatefulWidget {
  List<AllPagesNeedData> DataMenu = [];

  HomePage(this.DataMenu);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var db = new Mysql();
  List<MysqlDataOfpatient_rehabilitation> MysqlMenu = [];
  late List<AllPagesNeedData> DataMenu;
  final List<GridViewMenuData> menu = [
    GridViewMenuData(0, Icons.fitness_center, '語言訓練', Colors.pink),
    GridViewMenuData(1, Icons.health_and_safety, '生理需求', Colors.green),
    GridViewMenuData(
        2, Icons.content_paste_search, '認識失語症', Colors.orangeAccent),
    GridViewMenuData(3, Icons.settings, '基本設定', Colors.cyan),
  ];

  @override
  void initState() {
    DataMenu = widget.DataMenu;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return buildGridView(menu, context, DataMenu);
  }
}

//紀錄頁面
class RecordPage extends StatefulWidget {
  List<AllPagesNeedData> DataMenu = [];

  RecordPage(this.DataMenu);

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  var db = new Mysql();
  List<MysqlDataOfpatient_rehabilitation> MysqlMenu = [];
  late List<AllPagesNeedData> DataMenu;

  //取得Mysql裡patient_rehabilitation資料表的資料
  void _getMysqlData() {
    MysqlMenu.clear(); //初始化列表
    db.getConnection().then((conn) {
      String sql =
          "SELECT * FROM patient_rehabilitation WHERE id='${DataMenu[0].id}'";
      conn.query(sql).then((results) {
        print("連線成功!");
        for (var row in results) {
          setState(() {
            MysqlMenu.add(MysqlDataOfpatient_rehabilitation(row['id'],
                row['name'], row['time'], row['type'], row['score']));
          });
        }
      });
      conn.close();
    });
  }

  @override
  void initState() {
    _getMysqlData();
    DataMenu = widget.DataMenu;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //分隔線顏色
    Widget divider0 = const Divider(
      color: Colors.red,
      thickness: 2,
    );
    Widget divider1 = const Divider(
      color: Colors.orange,
      thickness: 2,
    );
    Widget divider2 = Divider(
      color: Colors.yellow[600],
      thickness: 2,
    );
    Widget divider3 = const Divider(
      color: Colors.green,
      thickness: 2,
    );
    Widget divider4 = const Divider(
      color: Colors.blue,
      thickness: 2,
    );
    Widget divider5 = Divider(
      color: Colors.blue[900],
      thickness: 2,
    );
    Widget divider6 = const Divider(
      color: Colors.purple,
      thickness: 2,
    );

    Widget ChooseDivider(int index) {
      return index % 7 == 0
          ? divider0
          : index % 7 == 1
              ? divider1
              : index % 7 == 2
                  ? divider2
                  : index % 7 == 3
                      ? divider3
                      : index % 7 == 4
                          ? divider4
                          : index % 7 == 5
                              ? divider5
                              : divider6;
    }

    return MaterialApp(
      builder: (BuildContext context, Widget? child) {
        final MediaQueryData data = MediaQuery.of(context);
        return MediaQuery(
          data: data.copyWith(
            textScaleFactor: choosetextscale(DataMenu),
          ),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: DarkMode(DataMenu[0].isdark, "background",
              Colors.grey.shade900, Colors.yellow.shade50),
          toolbarHeight: 10,
          flexibleSpace: Container(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "復健紀錄",
                  style: TextStyle(
                    fontSize: 30,
                    color: DarkMode(DataMenu[0].isdark, "Text", Colors.orange,
                        Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Container(
          color: DarkMode(DataMenu[0].isdark, "background", Colors.black,
              Colors.orange.shade50),
          padding: const EdgeInsets.all(20),
          child: ListView.separated(
            itemCount: MysqlMenu.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  border: Border.all(
                    width: 1,
                    color: DarkMode(DataMenu[0].isdark, "background",
                        Colors.grey.shade900, Colors.orange.shade50),
                  ),
                  color: DarkMode(DataMenu[0].isdark, "background",
                      Colors.grey.shade900, Colors.orange.shade50),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.access_time,
                    size: 50,
                    color: DarkMode(DataMenu[0].isdark, "Text"),
                  ),
                  title: Text(
                    '${MysqlMenu[index].type}',
                    style: TextStyle(
                      fontSize: 23,
                      color: DarkMode(DataMenu[0].isdark, "Text"),
                    ),
                  ),
                  subtitle: Text(
                    //日期格式轉換
                    formatDate(MysqlMenu[index].time, [yyyy, "-", mm, "-", dd]),
                    style: TextStyle(
                      fontSize: 18,
                      color: DarkMode(DataMenu[0].isdark, "Text"),
                    ),
                  ),
                  trailing:
                      // const Icon(
                      //   Icons.chevron_right,
                      //   size: 40,
                      // ),
                      Text(
                    '${MysqlMenu[index].score}',
                    style: TextStyle(
                      fontSize: 23,
                      color: DarkMode(DataMenu[0].isdark, "Text"),
                    ),
                  ),
                  onTap: () {},
                ),
              );
            },
            //選擇分隔線的
            separatorBuilder: (BuildContext context, int index) {
              return ChooseDivider(index);
            },
          ),
        ),
      ),
    );
  }
}

//新訊息頁面
class NewMessagePage extends StatefulWidget {
  List<AllPagesNeedData> DataMenu = [];

  NewMessagePage(this.DataMenu);

  @override
  _NewMessagePageState createState() => _NewMessagePageState();
}

class _NewMessagePageState extends State<NewMessagePage> {
  var db = new Mysql();
  List<MysqlDataOfpatient_rehabilitation> MysqlMenu = [];
  late List<AllPagesNeedData> DataMenu;
  List<ExpansionPanelListData> expansionpanellist_menu = [
    ExpansionPanelListData(
        false,
        "Lorem Ipsum is simplyen tnrere recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
        "12/31 0",
        false),
    ExpansionPanelListData(
        false,
        "Lorem Ipsum is simplyen tnrere recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
        "12/31 1",
        false),
    ExpansionPanelListData(
        false,
        "Lorem Ipsum is simplyen tnrere recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
        "12/31 2",
        false),
    ExpansionPanelListData(
        false,
        "Lorem Ipsum is simplyen tnrere recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
        "12/31 3",
        false),
    ExpansionPanelListData(
        false,
        "Lorem Ipsum is simplyen tnrere recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
        "12/31 4",
        false),
    ExpansionPanelListData(
        false,
        "Lorem Ipsum is simplyen tnrere recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
        "12/31 5",
        false),
    ExpansionPanelListData(
        false,
        "Lorem Ipsum is simplyen tnrere recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
        "12/31 6",
        false),
    ExpansionPanelListData(
        false,
        "Lorem Ipsum is simplyen tnrere recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
        "12/31 7",
        false),
  ];

  @override
  void initState() {
    DataMenu = widget.DataMenu;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (BuildContext context, Widget? child) {
        final MediaQueryData data = MediaQuery.of(context);
        return MediaQuery(
          data: data.copyWith(
            textScaleFactor: choosetextscale(DataMenu),
          ),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: DarkMode(DataMenu[0].isdark, "background"),
        appBar: AppBar(
          backgroundColor: DarkMode(DataMenu[0].isdark, "background",
              Colors.grey.shade900, Colors.green.shade50),
          toolbarHeight: 10,
          flexibleSpace: Container(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "訊息通知",
                  style: TextStyle(
                    fontSize: 30,
                    color: DarkMode(
                        DataMenu[0].isdark, "Text", Colors.green, Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Padding(
          padding:
              const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 0),
          child: Column(
            children: [
              if (expansionpanellist_menu.isEmpty)
                Column(
                  children: [
                    SwitchListTile(
                        dense: true,
                        activeColor: Colors.green,
                        contentPadding: const EdgeInsets.all(10),
                        value: DataMenu[0].RehabilitationNotice,
                        title: Text(
                          "復健通知",
                          style: TextStyle(
                            fontSize: 30,
                            color: DarkMode(DataMenu[0].isdark, "Text"),
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            DataMenu[0].RehabilitationNotice =
                                !DataMenu[0].RehabilitationNotice;
                          });
                        }),
                    Container(
                      width: double.infinity,
                      height: 2,
                      color: DarkMode(DataMenu[0].isdark, "Text",
                          Colors.green.shade500, Colors.white),
                    ),
                    SwitchListTile(
                        dense: true,
                        activeColor: Colors.green,
                        contentPadding: const EdgeInsets.all(10),
                        value: DataMenu[0].QuestionnaireNotice,
                        title: Text(
                          "問卷填寫通知",
                          style: TextStyle(
                            fontSize: 30,
                            color: DarkMode(DataMenu[0].isdark, "Text"),
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            DataMenu[0].QuestionnaireNotice =
                                !DataMenu[0].QuestionnaireNotice;
                          });
                        }),
                    Container(
                      width: double.infinity,
                      height: 2,
                      color: DarkMode(DataMenu[0].isdark, "Text",
                          Colors.green.shade500, Colors.white),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Divider(
                      color: DarkMode(DataMenu[0].isdark, "Text", Colors.grey,
                          Colors.white),
                      thickness: 2,
                    )
                  ],
                ),
              Expanded(
                child: ListView.separated(
                  itemCount: expansionpanellist_menu.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        if (index == 0)
                          Column(
                            children: [
                              SwitchListTile(
                                  dense: true,
                                  activeColor: Colors.green,
                                  contentPadding: const EdgeInsets.all(10),
                                  value: DataMenu[0].RehabilitationNotice,
                                  title: Text(
                                    "復健通知",
                                    style: TextStyle(
                                      fontSize: 30,
                                      color:
                                          DarkMode(DataMenu[0].isdark, "Text"),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      DataMenu[0].RehabilitationNotice =
                                          !DataMenu[0].RehabilitationNotice;
                                    });
                                  }),
                              Container(
                                width: double.infinity,
                                height: 2,
                                color: DarkMode(DataMenu[0].isdark, "Text",
                                    Colors.green.shade500, Colors.white),
                              ),
                              SwitchListTile(
                                  dense: true,
                                  activeColor: Colors.green,
                                  contentPadding: const EdgeInsets.all(10),
                                  value: DataMenu[0].QuestionnaireNotice,
                                  title: Text(
                                    "問卷填寫通知",
                                    style: TextStyle(
                                      fontSize: 30,
                                      color:
                                          DarkMode(DataMenu[0].isdark, "Text"),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      DataMenu[0].QuestionnaireNotice =
                                          !DataMenu[0].QuestionnaireNotice;
                                    });
                                  }),
                              Container(
                                width: double.infinity,
                                height: 2,
                                color: DarkMode(DataMenu[0].isdark, "Text",
                                    Colors.green.shade500, Colors.white),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      print("delete all");
                                      setState(() {
                                        expansionpanellist_menu.clear();
                                      });
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      size: 30,
                                      color: DarkMode(
                                          DataMenu[0].isdark, "Text"),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                color: DarkMode(DataMenu[0].isdark, "Text",
                                    Colors.grey, Colors.white),
                                thickness: 2,
                              )
                            ],
                          ),
                        ExpansionPanelList(
                            animationDuration:
                                const Duration(milliseconds: 500),
                            elevation: 0,
                            expandedHeaderPadding: const EdgeInsets.all(8),
                            children: [
                              ExpansionPanel(
                                backgroundColor: DarkMode(
                                    DataMenu[0].isdark,
                                    "background",
                                    Colors.grey.shade900,
                                    Colors.white),
                                isExpanded:
                                    expansionpanellist_menu[index].isopen,
                                canTapOnHeader: true,
                                //能按標題展開
                                headerBuilder:
                                    (BuildContext context, bool isExpanded) {
                                  return ListTile(
                                    leading: !expansionpanellist_menu[index]
                                            .isread
                                        ? Icon(Icons.circle,
                                            size: 16,
                                            color: Colors.greenAccent.shade200)
                                        : const Icon(Icons.circle_outlined,
                                            size: 16, color: Colors.grey),
                                    title: Text(
                                      "${expansionpanellist_menu[index].date}復健通知",
                                      style: TextStyle(
                                          color: DarkMode(
                                              DataMenu[0].isdark, "Text"),
                                          fontSize: 25,
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight:
                                              //未讀嗎?未讀的話粗體，已讀的話復原
                                              !expansionpanellist_menu[index]
                                                      .isread
                                                  ? FontWeight.bold
                                                  : FontWeight.normal),
                                    ),
                                  );
                                },
                                body: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Text(
                                        expansionpanellist_menu[index].detail,
                                        style: TextStyle(
                                          color: DarkMode(
                                              DataMenu[0].isdark, "Text"),
                                          fontSize: 25,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          print("delete index:$index");
                                          setState(() {
                                            expansionpanellist_menu[index]
                                                .isopen = false;
                                            expansionpanellist_menu
                                                .removeAt(index);
                                          });
                                        },
                                        icon: Icon(
                                          Icons.delete,
                                          size: 30,
                                          color: DarkMode(
                                              DataMenu[0].isdark, "Text"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            expansionCallback: (i, isExpanded) {
                              setState(() {
                                expansionpanellist_menu[index].isopen =
                                    !isExpanded;
                                expansionpanellist_menu[index].isread = true;
                              });
                            }),
                      ],
                    );
                  },
                  //選擇分隔線的
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      color: DarkMode(DataMenu[0].isdark, "Text",
                          Colors.grey.shade200, Colors.white),
                      thickness: 2,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//設定轉跳網址的expansionpanellist_menu的格式
// expansionpanellist_menu
class ExpansionPanelListData {
  ExpansionPanelListData(this.isread, this.detail, this.date, this.isopen);

  bool isread;
  String detail;
  String date;
  bool isopen;
}

//關於我們頁面
class AboutUsPage extends StatefulWidget {
  List<AllPagesNeedData> DataMenu = [];

  AboutUsPage(this.DataMenu);

  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  var db = new Mysql();
  List<MysqlDataOfpatient_rehabilitation> MysqlMenu = [];
  late List<AllPagesNeedData> DataMenu;

  @override
  void initState() {
    DataMenu = widget.DataMenu;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (BuildContext context, Widget? child) {
        final MediaQueryData data = MediaQuery.of(context);
        return MediaQuery(
          data: data.copyWith(
            textScaleFactor: choosetextscale(DataMenu),
          ),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: DarkMode(DataMenu[0].isdark, "background"),
        appBar: AppBar(
          backgroundColor: DarkMode(DataMenu[0].isdark, "background",
              Colors.grey.shade900, Colors.blue.shade50),
          toolbarHeight: 10,
          flexibleSpace: Container(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "關於我們",
                  style: TextStyle(
                    fontSize: 30,
                    color: DarkMode(
                        DataMenu[0].isdark, "Text", Colors.blue, Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Padding(
          padding:
              const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 0),
          child: ListView(
            children: [
              Card(
                color: DarkMode(
                  DataMenu[0].isdark,
                  "background",
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildAboutAs("發展單位", "高科大", DataMenu),
                    buildAboutAs("合作公司", "高醫", DataMenu),
                    buildAboutAs("APP使用", "", DataMenu),
                    buildAboutAs(
                        "最後更新時間",
                        "${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}",
                        DataMenu),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//關於我們頁面的list
Widget buildAboutAs(
    String title, String trailing, List<AllPagesNeedData> DataMenu) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: 28,
          color: DarkMode(DataMenu[0].isdark, "Text"),
        ),
      ),
      Text(
        trailing,
        style: TextStyle(
          fontSize: 24,
          color:
              DarkMode(DataMenu[0].isdark, "Text", Colors.grey, Colors.white),
        ),
      ),
      Container(
        width: double.infinity,
        height: 2,
        color: DarkMode(DataMenu[0].isdark, "Text", Colors.blue, Colors.white),
      ),
    ],
  );
}

//設定GridViewMenuData格式
class GridViewMenuData {
  GridViewMenuData(this.index, this.icon, this.title, this.self_color);

  final int index;
  final IconData icon;
  final String title;
  final Color self_color;
}

//BottomNavigationBarItem模板
BottomNavigationBarItem buildBottomNavigationBarView(
    IconData icon, Color color, String label, List<AllPagesNeedData> DataMenu) {
  return BottomNavigationBarItem(
    icon: Icon(
      icon,
      color: color,
    ),
    label: label,
  );
}

//ListTile模板
ListTile buildListTile(BuildContext context, int index, IconData icon,
    String title, List<AllPagesNeedData> DataMenu) {
  return ListTile(
    leading: Icon(
      icon,
      size: 30,
      color: DarkMode(
          DataMenu[0].isdark, "Text", Colors.grey.shade800, Colors.white),
    ),
    title: Text(title,
        style: TextStyle(
          color: DarkMode(
              DataMenu[0].isdark, "Text", Colors.grey.shade800, Colors.white),
          fontSize: 20,
        )),
    onTap: () {
      switch (index) {
        //社區交流頁面
        case 0:
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => CommunityCommunicationPage(DataMenu)));
          break;

        //相關連結頁面
        case 1:
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => RelateLinkPage(DataMenu)));
          break;

        //問卷系統頁面
        case 2:
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => QuestionnairePage(DataMenu)));
          break;

        //居家照護小知識頁面
        case 3:
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => HomeCarePage(DataMenu)));
          break;

        //放鬆音樂頁面
        case 4:
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => RelaxMusicPage(DataMenu)));
          break;

        //回首頁
        case 5:
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => MainPage(DataMenu)));
          break;

        //登出
        case 6:
          showAlertDialog(context); //顯示登出提示對話框
          break;
      }
    },
  );
}

//Ink+GridView模板
Widget buildGridView(List<GridViewMenuData> menu, BuildContext context,
    List<AllPagesNeedData> DataMenu) {
  DataMenu = DataMenu;
  return MaterialApp(
    builder: (BuildContext context, Widget? child) {
      final MediaQueryData data = MediaQuery.of(context);
      return MediaQuery(
        data: data.copyWith(
          textScaleFactor: choosetextscale(DataMenu),
        ),
        child: child!,
      );
    },
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Container(
        //是深色模式嗎?是的話背景黑色，不是的話背景白色
        color: DarkMode(DataMenu[0].isdark, "background", Colors.black,
            Colors.amber.shade50),
        padding: const EdgeInsets.only(top: 0, right: 20, left: 20, bottom: 20),
        child: GridView.builder(
          itemCount: menu.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              //寬高比
              childAspectRatio: 5 / 7,
              crossAxisCount: 2,
              crossAxisSpacing: 20.0,
              mainAxisSpacing: 20.0),
          itemBuilder: (BuildContext context, int index) {
            return Material(
              //是深色模式嗎?是的話背景黑色，不是的話背景白色
              color: DarkMode(DataMenu[0].isdark, "background", Colors.black,
                  Colors.amber.shade50),
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              child: Column(
                children: [
                  Ink(
                    decoration: BoxDecoration(
                      color: menu[index].self_color,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(30.0)),
                    ),
                    child: InkResponse(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(30.0)),
                      //控制高亮的參數
                      highlightColor: Colors.white24,
                      highlightShape: BoxShape.rectangle,
                      radius: 0.0,
                      splashColor: Colors.red,
                      //true表示要剪裁水波紋響應的界面；false不剪裁 ，如果控件是圓角不剪裁的話水波紋是矩形
                      containedInkWell: true,
                      onTap: () {
                        print(menu[index].title);
                        ChoosePage(context, menu[index].index, DataMenu);
                      },
                      child: Icon(
                        menu[index].icon,
                        size: 140,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    menu[index].title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 26,
                        //是深色模式嗎?不是的話字黑色，是的話字白色
                        color: DarkMode(DataMenu[0].isdark, "Text"),
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );
}

//跳轉首頁方格頁面
void ChoosePage(
    BuildContext context, int index, List<AllPagesNeedData> DataMenu) {
  switch (index) {
    //訓練頁面
    case 0:
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => TrainPage()),
      );
      break;

    //生理需求頁面
    case 1:
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => PhysiologicalPage()),
      );
      break;

    //認識失語症頁面
    case 2:
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => RecognizePage(DataMenu)),
      );
      break;

    //基本設定頁面
    case 3:
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => BasicSettingsPage(DataMenu)),
      );
      break;
  }
}

// 顯示確認登出對話框
void showAlertDialog(BuildContext context) {
  // Init
  AlertDialog dialog = AlertDialog(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(15)),
    ),
    title: RichText(
      text: const TextSpan(
        children: [
          WidgetSpan(
            child: Icon(
              Icons.warning,
              size: 30,
              color: Colors.yellow,
            ),
          ),
          TextSpan(
            text: "您確定要登出嗎?",
            style: TextStyle(fontSize: 25, color: Colors.black),
          ),
        ],
      ),
    ),
    actions: [
      Center(
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
                child: const Text(
                  "取消",
                  style: TextStyle(fontSize: 20, color: Colors.blue),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(
                width: 30,
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                ),
                child: const Text(
                  "登出",
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ],
  );

  // Show the dialog (showDialog() => showGeneralDialog())
  //登出確認框的動畫
  showGeneralDialog(
    context: context,
    pageBuilder: (context, anim1, anim2) {
      return Wrap();
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return Transform(
        transform: Matrix4.translationValues(
          0.0,
          (1.0 - Curves.easeInOut.transform(anim1.value)) * 400,
          0.0,
        ),
        child: dialog,
      );
    },
    transitionDuration: const Duration(milliseconds: 400),
  );
}