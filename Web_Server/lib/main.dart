import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobius/dataTable/TlData.dart';
import 'package:flutter_mobius/model/con.dart';
import 'package:flutter_mobius/model/con2.dart';
import 'package:flutter_mobius/model/reqTlInfo.dart';
import 'package:flutter_mobius/provider/NetworkProvider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:intl/intl.dart';

void main() async {
  await initializeDefault();
  runApp(const MaterialApp(home: MyApp()));
}

Future<void> initializeDefault() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoogleMapController mapController;
  final List<Marker> _markers = [];
  late Timer _timer1;
  late Timer _timer2;
  late Timer _timer3;
  String color1 = "red";
  String color2 = "red";
  String color3 = "red";
  int selectStats = 0;

  Con selectInfo = Con();

  List<Con> infoDatas = [];
  List<Con2> stateDatas = [];

  List<Map<String, dynamic>> dataList = [];

  Con2 selectState = Con2();

  int selectTL = 0;

  int targetMarker = 99;

  late BitmapDescriptor redImage;
  late BitmapDescriptor greenImage;
  late BitmapDescriptor redImage_w;
  late BitmapDescriptor greenImage_w;
  late BitmapDescriptor selectMarker;
  int time1 = 0;
  // MQTTClientManager mqttClientManager = MQTTClientManager();

  ScrollController scrollController = ScrollController();

  var targetView = false;

  final LatLng _center = const LatLng(37.402327, 126.970956);

  final LatLng trafficLights1 = const LatLng(37.402050, 126.969267);
  final LatLng trafficLights2 = const LatLng(37.401620, 126.970123);
  final LatLng trafficLights3 = const LatLng(37.401677, 126.970350);

  DataTableSource? _data;

  late FirebaseFirestore db;

  final TextEditingController _messageInputController_red =
      TextEditingController();
  final TextEditingController _messageInputController_green =
      TextEditingController();

  List<Map<String, dynamic>> weekList = [];
  List<int> addTime = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  bool isFirst = true;

  @override
  void initState() {
    super.initState();
    db = FirebaseFirestore.instance;
    setColor();
  }

  setColor() async {
    redImage = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(24, 65)), "assets/red.png");
    greenImage = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(24, 65)), "assets/green.png");
    redImage_w = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(125, 108)), "assets/red_w.png");
    greenImage_w = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(125, 108)), "assets/green_w.png");
    selectMarker = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(25, 25)),
        "assets/select_marker.png");

    getTlState();
    setStreamData();
  }

  @override
  void dispose() {
    _timer1.cancel();
    _timer2.cancel();
    _timer3.cancel();
    super.dispose();
  }

  void setStreamData() {
    final docRef = db.collection("STL");
    docRef.snapshots().listen(
      (event) {
        if (isFirst) {
          isFirst = false;
          return;
        }
        Map<String, dynamic> data = event.docs.last.data();

        if (data['ready']) {
          if (addTime[data['tl'] - 1] == 0) {
            stateDatas[data['tl'] - 1].gTime =
                stateDatas[data['tl'] - 1].gTime! + 10;

            setState(() {
              var index = data['tl'] - 1;
              targetMarker = data['tl'] - 1;

              _markers[index] = Marker(
                markerId: MarkerId("${index + 1}"),
                draggable: false,
                icon: stateDatas[data['tl'] - 1].state == 'green'
                    ? greenImage_w
                    : redImage_w,
                onTap: () => {
                  setState(() {
                    selectTL = index + 1;
                    selectInfo = infoDatas[index];
                    selectState = stateDatas[index];
                    targetView = !targetView;
                    _messageInputController_red.text =
                        selectState.rTime.toString();
                    _messageInputController_green.text =
                        selectState.gTime.toString();
                  }),
                },
                position: LatLng(infoDatas[index].lat!, infoDatas[index].lang!),
              );
            });
          }

          addTime[data['tl'] - 1] += 1;
        } else if (!data['ready']) {
          addTime[data['tl'] - 1] -= 1;

          if (addTime[data['tl'] - 1] < 0) {
            addTime[data['tl'] - 1] = 0;
          }

          if (addTime[data['tl'] - 1] == 0) {
            stateDatas[data['tl'] - 1].gTime =
                stateDatas[data['tl'] - 1].gTime! - 10;

            setState(() {
              targetMarker = 99;
              var index = data['tl'] - 1;

              _markers[index] = Marker(
                markerId: MarkerId("${index + 1}"),
                draggable: false,
                icon: stateDatas[data['tl'] - 1].state == 'green'
                    ? greenImage
                    : redImage,
                onTap: () => {
                  setState(() {
                    selectTL = index + 1;
                    selectInfo = infoDatas[index];
                    selectState = stateDatas[index];
                    targetView = !targetView;
                    _messageInputController_red.text =
                        selectState.rTime.toString();
                    _messageInputController_green.text =
                        selectState.gTime.toString();
                  }),
                },
                position: LatLng(infoDatas[index].lat!, infoDatas[index].lang!),
              );
            });
          }
        }
      },
      onError: (error) => print("Listen failed: $error"),
    );
  }

  void getCiInfo() {
    print('getCiInfo');
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      print('requestCi');
      var ciData = await NetworkProvider().requestGroupCi();
      print('requestGroupCi');
      for (var i = 0; i < ciData!.m2mAgr!.m2mRsp!.length; i++) {
        if (ciData.m2mAgr!.m2mRsp![i].pc!.m2mRsp!.m2mCin == null) continue;
        var reqData = reqTlInfo(m2mCin: M2mCins(con: Con()));
        reqData.m2mCin!.con!.t0003 = 0;
        reqData.m2mCin!.con!.t0306 = 0;
        reqData.m2mCin!.con!.t0609 = 0;
        reqData.m2mCin!.con!.t0912 = 0;
        reqData.m2mCin!.con!.t1215 = 0;
        reqData.m2mCin!.con!.t1518 = 0;
        reqData.m2mCin!.con!.t1821 = 0;
        reqData.m2mCin!.con!.t2124 = 0;

        reqData.m2mCin!.con!.j0003 = 0;
        reqData.m2mCin!.con!.j0306 = 0;
        reqData.m2mCin!.con!.j0609 = 0;
        reqData.m2mCin!.con!.j0912 = 0;
        reqData.m2mCin!.con!.j1215 = 0;
        reqData.m2mCin!.con!.j1518 = 0;
        reqData.m2mCin!.con!.j1821 = 0;
        reqData.m2mCin!.con!.j2124 = 0;

        reqData.m2mCin!.con!.preCount = 0;
        reqData.m2mCin!.con!.weakCount = 0;
        reqData.m2mCin!.con!.chiCount = 0;
        reqData.m2mCin!.con!.disCount = 0;

        reqData.m2mCin!.con!.jkCount = 0;

        for (var element in ciData.m2mAgr!.m2mRsp![i].pc!.m2mRsp!.m2mCin!) {
          if (reqData.m2mCin!.con!.avTime == null) {
            reqData.m2mCin!.con!.avTime = element.con!.wTime!;
          } else {
            reqData.m2mCin!.con!.avTime =
                reqData.m2mCin!.con!.avTime! + element.con!.wTime!;
          }

          if (element.con!.wKind == 'jaywalking') {
            reqData.m2mCin!.con!.jkCount = reqData.m2mCin!.con!.jkCount! + 1;
          }

          switch (element.con!.userState) {
            case 'pregnant':
              reqData.m2mCin!.con!.preCount =
                  reqData.m2mCin!.con!.preCount! + 1;

              break;
            case 'weak':
              reqData.m2mCin!.con!.weakCount =
                  reqData.m2mCin!.con!.weakCount! + 1;

              break;
            case 'children':
              reqData.m2mCin!.con!.chiCount =
                  reqData.m2mCin!.con!.chiCount! + 1;

              break;
            case 'disabled':
              reqData.m2mCin!.con!.disCount =
                  reqData.m2mCin!.con!.disCount! + 1;

              break;
            default:
              break;
          }

          DateTime createdDate = DateTime.parse(element.con!.timestamp!);

          if (element.con!.ais! == 'normal') {
            if (0 <= createdDate.hour && createdDate.hour < 3) {
              reqData.m2mCin!.con!.t0003 = reqData.m2mCin!.con!.t0003! + 1;
            } else if (3 <= createdDate.hour && createdDate.hour < 6) {
              reqData.m2mCin!.con!.t0306 = reqData.m2mCin!.con!.t0306! + 1;
            } else if (6 <= createdDate.hour && createdDate.hour < 9) {
              reqData.m2mCin!.con!.t0609 = reqData.m2mCin!.con!.t0609! + 1;
            } else if (9 <= createdDate.hour && createdDate.hour < 12) {
              reqData.m2mCin!.con!.t0912 = reqData.m2mCin!.con!.t0912! + 1;
            } else if (12 <= createdDate.hour && createdDate.hour < 15) {
              reqData.m2mCin!.con!.t1215 = reqData.m2mCin!.con!.t1215! + 1;
            } else if (15 <= createdDate.hour && createdDate.hour < 18) {
              reqData.m2mCin!.con!.t1518 = reqData.m2mCin!.con!.t1518! + 1;
            } else if (18 <= createdDate.hour && createdDate.hour < 21) {
              reqData.m2mCin!.con!.t1821 = reqData.m2mCin!.con!.t1821! + 1;
            } else if (21 <= createdDate.hour && createdDate.hour < 24) {
              reqData.m2mCin!.con!.t2124 = reqData.m2mCin!.con!.t2124! + 1;
            }
          } else {
            if (0 <= createdDate.hour && createdDate.hour < 3) {
              reqData.m2mCin!.con!.j0003 = reqData.m2mCin!.con!.j0003! + 1;
            } else if (3 <= createdDate.hour && createdDate.hour < 6) {
              reqData.m2mCin!.con!.j0306 = reqData.m2mCin!.con!.j0306! + 1;
            } else if (6 <= createdDate.hour && createdDate.hour < 9) {
              reqData.m2mCin!.con!.j0609 = reqData.m2mCin!.con!.j0609! + 1;
            } else if (9 <= createdDate.hour && createdDate.hour < 12) {
              reqData.m2mCin!.con!.j0912 = reqData.m2mCin!.con!.j0912! + 1;
            } else if (12 <= createdDate.hour && createdDate.hour < 15) {
              reqData.m2mCin!.con!.j1215 = reqData.m2mCin!.con!.j1215! + 1;
            } else if (15 <= createdDate.hour && createdDate.hour < 18) {
              reqData.m2mCin!.con!.j1518 = reqData.m2mCin!.con!.j1518! + 1;
            } else if (18 <= createdDate.hour && createdDate.hour < 21) {
              reqData.m2mCin!.con!.j1821 = reqData.m2mCin!.con!.j1821! + 1;
            } else if (21 <= createdDate.hour && createdDate.hour < 24) {
              reqData.m2mCin!.con!.j2124 = reqData.m2mCin!.con!.j2124! + 1;
            }
          }
        }

        reqData.m2mCin!.con!.avTime = reqData.m2mCin!.con!.avTime! ~/
            ciData.m2mAgr!.m2mRsp![i].pc!.m2mRsp!.m2mCin!.length; // 평균 시간
        reqData.m2mCin!.con!.id = infoDatas[i].id;
        reqData.m2mCin!.con!.lat = infoDatas[i].lat;
        reqData.m2mCin!.con!.lang = infoDatas[i].lang;

        print('requestTlInfo_pre');
        await NetworkProvider()
            .requestTlInfo('TL${i + 1}', reqData.m2mCin!.con!);
        print('requestTlInfo_pro');
      }
      getTlInfo();
    });
  }

  void getTlState() async {
    var stateData = await NetworkProvider().requestTlGroupState();
    if (stateData != null) {
      for (var element in stateData.m2mAgr!.m2mRsp!) {
        stateDatas.add(element.pc!.m2mCin!.con!);
      }
    }

    print('신호등 상태 수신 완료');

    var infoData = await NetworkProvider().requestTlGroupInfo();
    if (infoData != null) {
      for (var element in infoData.m2mAgr!.m2mRsp!) {
        infoDatas.add(element.pc!.m2mCin!.con!);
      }
    }

    for (var element in infoDatas) {
      Map<String, dynamic> p = {
        'id': element.id,
        'lat_lang': "${element.lat}, ${element.lang}",
        'jk_count': element.jkCount,
        'z_count': element.j0003! +
            element.j0306! +
            element.j0609! +
            element.j0912! +
            element.j1215! +
            element.j1518! +
            element.j1821! +
            element.j2124!,
        't_count': element.t0003! +
            element.t0306! +
            element.t0609! +
            element.t0912! +
            element.t1215! +
            element.t1518! +
            element.t1821! +
            element.t2124!,
        'w_count': element.weakCount,
        'c_count': element.chiCount,
        'p_count': element.preCount,
        'd_count': element.disCount,
        'av_time': element.avTime
      };
      dataList.add(p);
    }

    setState(() {
      _data = TlData(data: dataList);
    });

    _setMapMarker();

    for (var i = 0; i < stateDatas.length; i++) {
      controllerTL(stateDatas[i], i);
    }

    getCiInfo();
  }

  void getTlInfo() async {
    var infoData = await NetworkProvider().requestTlGroupInfo();

    infoDatas.clear();
    dataList.clear();

    if (infoData != null) {
      for (var element in infoData.m2mAgr!.m2mRsp!) {
        infoDatas.add(element.pc!.m2mCin!.con!);
      }
    }

    for (var element in infoDatas) {
      Map<String, dynamic> p = {
        'id': element.id,
        'lat_lang': "${element.lat}, ${element.lang}",
        'jk_count': element.jkCount,
        'z_count': element.j0003! +
            element.j0306! +
            element.j0609! +
            element.j0912! +
            element.j1215! +
            element.j1518! +
            element.j1821! +
            element.j2124!,
        't_count': element.t0003! +
            element.t0306! +
            element.t0609! +
            element.t0912! +
            element.t1215! +
            element.t1518! +
            element.t1821! +
            element.t2124!,
        'w_count': element.weakCount,
        'c_count': element.chiCount,
        'p_count': element.preCount,
        'd_count': element.disCount,
        'av_time': element.avTime
      };
      dataList.add(p);
    }

    setState(() {
      _data = TlData(data: dataList);
    });

    print('신호등 정보 수신 완료');
  }

  void controllerTL(Con2 data, int index) {
    // print('${index + 1}번 신호등 현재 : ${data.state}');
    // print(
    //     '${index + 1}번 신호등 변경 대기 시간 : ${data.state == 'green' ? data.gTime! : data.rTime!}');
    Timer(Duration(seconds: data.state == 'green' ? data.gTime! : data.rTime!),
        () async {
      var sendData = data;
      sendData.state = sendData.state == 'green' ? 'red' : 'green';
      var now = DateTime.now(); //반드시 다른 함수에서 해야함, Mypage같은 클래스에서는 사용 불가능
      String formatDate = DateFormat('yyyy-MM-dd HH:mm:ss')
          .format(now); //format변경  2023-00-00 00:00:00
      sendData.time = formatDate;
      var resp =
          await NetworkProvider().requestTlState('TL${index + 1}', sendData);
      stateDatas[index] = resp!.m2mCin!.con!;
      setState(
        () {
          if (selectTL == index + 1) {
            selectState = resp.m2mCin!.con!;
          }
          _markers[index] = Marker(
            markerId: MarkerId("${index + 1}"),
            draggable: false,
            icon: index == targetMarker
                ? resp.m2mCin!.con!.state! == 'green'
                    ? greenImage_w
                    : redImage_w
                : resp.m2mCin!.con!.state! == 'green'
                    ? greenImage
                    : redImage,
            onTap: () => {
              setState(() {
                selectTL = index + 1;
                selectInfo = infoDatas[index];
                selectState = stateDatas[index];
                targetView = !targetView;
                _messageInputController_red.text = selectState.rTime.toString();
                _messageInputController_green.text =
                    selectState.gTime.toString();
              }),
            },
            position: LatLng(infoDatas[index].lat!, infoDatas[index].lang!),
          );
        },
      );
      controllerTL(stateDatas[index], index);
    });
  }

  void _setMapMarker() async {
    setState(
      () {
        for (var i = 0; i < stateDatas.length; i++) {
          _markers.add(Marker(
            markerId: MarkerId('${i + 1}'),
            draggable: false,
            icon: stateDatas[i].state! == 'green' ? greenImage : redImage,
            onTap: () => {
              setState(() {
                selectTL = i + 1;
                selectInfo = infoDatas[i];
                selectState = stateDatas[i];
                targetView = !targetView;
                _messageInputController_red.text = selectState.rTime.toString();
                _messageInputController_green.text =
                    selectState.gTime.toString();
              }),
            },
            position: LatLng(infoDatas[i].lat!, infoDatas[i].lang!),
          ));
        }
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: _data == null ? 1 : 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Smart Traffic Light'),
            backgroundColor: const Color(0xff2e3f4f),
            bottom: TabBar(tabs: [
              const Tab(
                text: "Map",
              ),
              if (_data != null)
                const Tab(
                  text: "Statistics",
                )
            ]),
          ),
          body: TabBarView(
            children: [
              Stack(
                children: [
                  GoogleMap(
                    mapToolbarEnabled: false,
                    scrollGesturesEnabled: !targetView,
                    markers: Set.from(_markers),
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 18.5,
                    ),
                  ),
                  if (targetView)
                    Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration:
                          BoxDecoration(color: Colors.black.withOpacity(0.5)),
                    ),
                  if (targetView) viewTlTarget(),
                ],
              ),
              if (_data != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 50, left: 100),
                      child: Row(
                        children: [
                          Container(
                            child: const Padding(
                              padding: EdgeInsets.all(15.0),
                              child: Text(
                                'Select Priority',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                selectStats = 0;
                                var datas = dataList
                                  ..sort((a, b) => a['id'].compareTo(b['id']));
                                _data = TlData(data: dataList);
                              });
                            },
                            hoverColor: Colors.transparent,
                            child: Container(
                              decoration: selectStats == 0
                                  ? BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 88, 108, 126),
                                      borderRadius: BorderRadius.circular(30),
                                    )
                                  : BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                          width: 1,
                                          color: const Color.fromARGB(
                                              255, 104, 104, 104)),
                                    ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 30, right: 30, top: 15, bottom: 15),
                                child: Text(
                                  'ID',
                                  style: TextStyle(
                                      color: selectStats == 0
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                selectStats = 1;
                                var datas = dataList
                                  ..sort((b, a) =>
                                      a['jk_count'].compareTo(b['jk_count']));
                                _data = TlData(data: dataList);
                              });
                            },
                            hoverColor: Colors.transparent,
                            child: Container(
                              decoration: selectStats == 1
                                  ? BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 88, 108, 126),
                                      borderRadius: BorderRadius.circular(30),
                                    )
                                  : BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                          width: 1,
                                          color: const Color.fromARGB(
                                              255, 104, 104, 104)),
                                    ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text(
                                  'Jaywalking',
                                  style: TextStyle(
                                      color: selectStats == 1
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                selectStats = 2;
                                var datas = dataList
                                  ..sort((b, a) =>
                                      a['z_count'].compareTo(b['z_count']));
                                _data = TlData(data: dataList);
                              });
                            },
                            hoverColor: Colors.transparent,
                            child: Container(
                              decoration: selectStats == 2
                                  ? BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 88, 108, 126),
                                      borderRadius: BorderRadius.circular(30),
                                    )
                                  : BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                          width: 1,
                                          color: const Color.fromARGB(
                                              255, 104, 104, 104)),
                                    ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text(
                                  'Smombie',
                                  style: TextStyle(
                                      color: selectStats == 2
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                selectStats = 3;
                                var datas = dataList
                                  ..sort((b, a) =>
                                      a['t_count'].compareTo(b['t_count']));
                                _data = TlData(data: dataList);
                              });
                            },
                            hoverColor: Colors.transparent,
                            child: Container(
                              decoration: selectStats == 3
                                  ? BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 88, 108, 126),
                                      borderRadius: BorderRadius.circular(30),
                                    )
                                  : BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                          width: 1,
                                          color: const Color.fromARGB(
                                              255, 104, 104, 104)),
                                    ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text(
                                  'Crosswalker',
                                  style: TextStyle(
                                      color: selectStats == 3
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                selectStats = 4;
                                var datas = dataList
                                  ..sort((b, a) =>
                                      a['w_count'].compareTo(b['w_count']));
                                _data = TlData(data: dataList);
                              });
                            },
                            hoverColor: Colors.transparent,
                            child: Container(
                              decoration: selectStats == 4
                                  ? BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 88, 108, 126),
                                      borderRadius: BorderRadius.circular(30),
                                    )
                                  : BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                          width: 1,
                                          color: const Color.fromARGB(
                                              255, 104, 104, 104)),
                                    ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text(
                                  'Old',
                                  style: TextStyle(
                                      color: selectStats == 4
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                selectStats = 5;
                                var datas = dataList
                                  ..sort((b, a) =>
                                      a['c_count'].compareTo(b['c_count']));
                                _data = TlData(data: dataList);
                              });
                            },
                            hoverColor: Colors.transparent,
                            child: Container(
                              decoration: selectStats == 5
                                  ? BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 88, 108, 126),
                                      borderRadius: BorderRadius.circular(30),
                                    )
                                  : BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                          width: 1,
                                          color: const Color.fromARGB(
                                              255, 104, 104, 104)),
                                    ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text(
                                  'Children',
                                  style: TextStyle(
                                      color: selectStats == 5
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                selectStats = 6;
                                var datas = dataList
                                  ..sort((b, a) =>
                                      a['p_count'].compareTo(b['p_count']));
                                _data = TlData(data: dataList);
                              });
                            },
                            hoverColor: Colors.transparent,
                            child: Container(
                              decoration: selectStats == 6
                                  ? BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 88, 108, 126),
                                      borderRadius: BorderRadius.circular(30),
                                    )
                                  : BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                          width: 1,
                                          color: const Color.fromARGB(
                                              255, 104, 104, 104)),
                                    ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text(
                                  'Pregnant',
                                  style: TextStyle(
                                      color: selectStats == 6
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                selectStats = 7;
                                var datas = dataList
                                  ..sort((b, a) =>
                                      a['d_count'].compareTo(b['d_count']));
                                _data = TlData(data: dataList);
                              });
                            },
                            hoverColor: Colors.transparent,
                            child: Container(
                              decoration: selectStats == 7
                                  ? BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 88, 108, 126),
                                      borderRadius: BorderRadius.circular(30),
                                    )
                                  : BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                          width: 1,
                                          color: const Color.fromARGB(
                                              255, 104, 104, 104)),
                                    ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text(
                                  'Disabled',
                                  style: TextStyle(
                                      color: selectStats == 7
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                selectStats = 8;
                                var datas = dataList
                                  ..sort((b, a) =>
                                      a['av_time'].compareTo(b['av_time']));
                                _data = TlData(data: dataList);
                              });
                            },
                            hoverColor: Colors.transparent,
                            child: Container(
                              decoration: selectStats == 8
                                  ? BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 88, 108, 126),
                                      borderRadius: BorderRadius.circular(30),
                                    )
                                  : BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                          width: 1,
                                          color: const Color.fromARGB(
                                              255, 104, 104, 104)),
                                    ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text(
                                  'Average crossing time',
                                  style: TextStyle(
                                      color: selectStats == 8
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 100, top: 40),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                final List<Marker> geoMarkers = [];
                                final List<LatLng> polyPoint = [];
                                final Set<Polyline> polyline = {};
                                int maxCount = 0;

                                return Center(
                                  child: Container(
                                    height: 600,
                                    width: 1000,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Stack(children: [
                                      StatefulBuilder(
                                        builder: (BuildContext context,
                                            StateSetter setState) {
                                          return Center(
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(30),
                                                topRight: Radius.circular(30),
                                                bottomRight:
                                                    Radius.circular(30),
                                                bottomLeft: Radius.circular(30),
                                              ),
                                              child: Align(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: GoogleMap(
                                                  polylines: polyline,
                                                  onMapCreated: _onMapCreated,
                                                  initialCameraPosition:
                                                      CameraPosition(
                                                    target: _center,
                                                    zoom: 18,
                                                  ),
                                                  markers: Set.from(geoMarkers),
                                                  onTap: (argument) {
                                                    setState(() {
                                                      if (maxCount > 3) {
                                                        return;
                                                      }
                                                      polyPoint.add(LatLng(
                                                          argument.latitude +
                                                              0.00005,
                                                          argument.longitude));
                                                      geoMarkers.add(Marker(
                                                        markerId: MarkerId(
                                                            '$maxCount'),
                                                        icon: selectMarker,
                                                        draggable: false,
                                                        position: argument,
                                                      ));
                                                      polyline.add(Polyline(
                                                          width: 5,
                                                          polylineId:
                                                              const PolylineId(
                                                                  '1'),
                                                          points: polyPoint,
                                                          color: Colors.red));
                                                      maxCount++;

                                                      if (maxCount == 4) {
                                                        polyPoint
                                                            .add(polyPoint[0]);
                                                        polyline.add(Polyline(
                                                            width: 5,
                                                            polylineId:
                                                                const PolylineId(
                                                                    '2'),
                                                            points: polyPoint,
                                                            color: Colors.red));
                                                      }
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Container(
                                              child: const Icon(
                                                Icons.close,
                                                size: 40,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 80,
                                        bottom: 20,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              List<Map<String, dynamic>> datas =
                                                  [];

                                              datas.add(dataList[1]);
                                              datas.add(dataList[2]);
                                              datas.add(dataList[3]);
                                              datas.add(dataList[10]);
                                              datas.add(dataList[12]);
                                              datas.add(dataList[18]);

                                              _data = TlData(data: datas);

                                              Navigator.pop(context);
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xff2e404e),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.only(
                                                  left: 30,
                                                  right: 30,
                                                  top: 15,
                                                  bottom: 15),
                                              child: DefaultTextStyle(
                                                style: TextStyle(),
                                                child: Text(
                                                  'Apply',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ]),
                                  ),
                                );
                              },
                            );
                          });
                        },
                        hoverColor: Colors.transparent,
                        child: Container(
                          width: 300,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 94, 141, 242),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/location.png',
                                  width: 30,
                                  height: 30,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text(
                                  'Search for traffic lights on a map',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10, left: 100, right: 100),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          cardColor: const Color.fromARGB(255, 244, 244, 244),
                          dividerColor:
                              const Color.fromARGB(255, 185, 185, 185),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  width: 1,
                                  color: const Color.fromARGB(
                                      255, 185, 185, 185))),
                          child: PaginatedDataTable(
                            columns: const [
                              DataColumn(
                                  label: Expanded(
                                child: Text(
                                  'Traffic light\nID',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )),
                              DataColumn(
                                  label: Expanded(
                                child: Text(
                                  'lat,long',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )),
                              DataColumn(
                                  label: Expanded(
                                child: Text(
                                  textAlign: TextAlign.center,
                                  'Jaywalking\n(person)',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                              DataColumn(
                                  label: Expanded(
                                child: Text(
                                  textAlign: TextAlign.center,
                                  'Smombie\n(person)',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                              DataColumn(
                                  label: Expanded(
                                child: Text(
                                  textAlign: TextAlign.center,
                                  'Crosswalker\n(person)',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                              DataColumn(
                                  label: Expanded(
                                child: Text(
                                  textAlign: TextAlign.center,
                                  'Old\n(person)',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                              DataColumn(
                                  label: Expanded(
                                child: Text(
                                  textAlign: TextAlign.center,
                                  'Children\n(person)',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                              DataColumn(
                                  label: Expanded(
                                child: Text(
                                  textAlign: TextAlign.center,
                                  'Pregnant\n(person)',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                              DataColumn(
                                  label: Expanded(
                                child: Text(
                                  textAlign: TextAlign.center,
                                  'Disabled\n(person)',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                              DataColumn(
                                  label: Expanded(
                                child: Text(
                                  textAlign: TextAlign.center,
                                  'Average creossing time\n(s)',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                            ],
                            source: _data!,
                            header: const Text('Traffic light data inquiry'),
                            columnSpacing: 50,
                            horizontalMargin: 20,
                            rowsPerPage: 8,
                            showCheckboxColumn: false,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  Padding viewTlTarget() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(15)),
          height: double.infinity,
          width: 350,
          child: Column(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  decoration: const BoxDecoration(
                      color: Color(0xffffc500),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15))),
                  width: 350,
                  height: 100,
                  child: Center(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  selectTL = 0;
                                  targetView = false;
                                });
                              },
                              icon: const Icon(Icons.cancel)),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: const [
                            Expanded(
                              child: Text(
                                'Traffic Light',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 8, bottom: 8, right: 20, left: 15),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'ID',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${selectInfo.id}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Container(
                            decoration:
                                const BoxDecoration(color: Color(0xfffbfbfb)),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Jaywalking',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    selectInfo.jkCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Container(
                            decoration:
                                const BoxDecoration(color: Color(0xfffbfbfb)),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Smombie',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Column(
                                              children: [
                                                const Text(
                                                  '00h~03h',
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                    selectInfo.j0003.toString(),
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5, bottom: 5),
                                              child: Container(
                                                  width: 1,
                                                  height: 20,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Color(
                                                              0xffb0b0b0))),
                                            ),
                                            Column(
                                              children: [
                                                const Text(
                                                  '03h~06h',
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                    selectInfo.j0306.toString(),
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5, bottom: 5),
                                              child: Container(
                                                  width: 1,
                                                  height: 20,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Color(
                                                              0xffb0b0b0))),
                                            ),
                                            Column(
                                              children: [
                                                const Text(
                                                  '06h~09h',
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                    selectInfo.j0609.toString(),
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Column(
                                              children: [
                                                const Text(
                                                  '09h~12h',
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                    selectInfo.j0912.toString(),
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5, bottom: 5),
                                              child: Container(
                                                  width: 1,
                                                  height: 20,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Color(
                                                              0xffb0b0b0))),
                                            ),
                                            Column(
                                              children: [
                                                const Text(
                                                  '12h~15h',
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                    selectInfo.j1215.toString(),
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5, bottom: 5),
                                              child: Container(
                                                  width: 1,
                                                  height: 20,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Color(
                                                              0xffb0b0b0))),
                                            ),
                                            Column(
                                              children: [
                                                const Text(
                                                  '15h~18h',
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                    selectInfo.j1518.toString(),
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Column(
                                              children: [
                                                const Text(
                                                  '18h~21h',
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                    selectInfo.j1821.toString(),
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5, bottom: 5),
                                              child: Container(
                                                  width: 1,
                                                  height: 20,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Color(
                                                              0xffb0b0b0))),
                                            ),
                                            Column(
                                              children: [
                                                const Text(
                                                  '21h~24h',
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                    selectInfo.j2124.toString(),
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                            Opacity(
                                              opacity: 0,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5, bottom: 5),
                                                child: Container(
                                                    width: 1,
                                                    height: 20,
                                                    decoration:
                                                        const BoxDecoration(
                                                            color: Color(
                                                                0xffb0b0b0))),
                                              ),
                                            ),
                                            Opacity(
                                              opacity: 0,
                                              child: Column(
                                                children: const [
                                                  Text(
                                                    '21h~24h',
                                                    style:
                                                        TextStyle(fontSize: 10),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text('100',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Container(
                            decoration:
                                const BoxDecoration(color: Color(0xfffbfbfb)),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'a crossing person',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Column(
                                              children: [
                                                const Text(
                                                  '00h~03h',
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                    selectInfo.t0003.toString(),
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5, bottom: 5),
                                              child: Container(
                                                  width: 1,
                                                  height: 20,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Color(
                                                              0xffb0b0b0))),
                                            ),
                                            Column(
                                              children: [
                                                const Text(
                                                  '03h~06h',
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                    selectInfo.t0306.toString(),
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5, bottom: 5),
                                              child: Container(
                                                  width: 1,
                                                  height: 20,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Color(
                                                              0xffb0b0b0))),
                                            ),
                                            Column(
                                              children: [
                                                const Text(
                                                  '06h~09h',
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                    selectInfo.t0609.toString(),
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Column(
                                              children: [
                                                const Text(
                                                  '09h~12h',
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                    selectInfo.t0912.toString(),
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5, bottom: 5),
                                              child: Container(
                                                  width: 1,
                                                  height: 20,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Color(
                                                              0xffb0b0b0))),
                                            ),
                                            Column(
                                              children: [
                                                const Text(
                                                  '12h~15h',
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                    selectInfo.t1215.toString(),
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5, bottom: 5),
                                              child: Container(
                                                  width: 1,
                                                  height: 20,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Color(
                                                              0xffb0b0b0))),
                                            ),
                                            Column(
                                              children: [
                                                const Text(
                                                  '15h~18h',
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                    selectInfo.t1518.toString(),
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Column(
                                              children: [
                                                const Text(
                                                  '18h~21h',
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                    selectInfo.t1821.toString(),
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5, bottom: 5),
                                              child: Container(
                                                  width: 1,
                                                  height: 20,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Color(
                                                              0xffb0b0b0))),
                                            ),
                                            Column(
                                              children: [
                                                const Text(
                                                  '21h~24h',
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                    selectInfo.t2124.toString(),
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                            Opacity(
                                              opacity: 0,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5, bottom: 5),
                                                child: Container(
                                                    width: 1,
                                                    height: 20,
                                                    decoration:
                                                        const BoxDecoration(
                                                            color: Color(
                                                                0xffb0b0b0))),
                                              ),
                                            ),
                                            Opacity(
                                              opacity: 0,
                                              child: Column(
                                                children: const [
                                                  Text(
                                                    '21h~24h',
                                                    style:
                                                        TextStyle(fontSize: 10),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text('100',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Container(
                            decoration:
                                const BoxDecoration(color: Color(0xfffbfbfb)),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'lat/long',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${selectInfo.lat}, ${selectInfo.lang}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Container(
                            decoration:
                                const BoxDecoration(color: Color(0xfffbfbfb)),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'state',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  selectState.state == 'green'
                                      ? Image.asset(
                                          'assets/s_green.png',
                                          width: 30,
                                          height: 30,
                                        )
                                      : Image.asset(
                                          'assets/s_red.png',
                                          width: 30,
                                          height: 30,
                                        )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Container(
                            decoration:
                                const BoxDecoration(color: Color(0xfffbfbfb)),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Set the time remaining on the red light',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 35,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                                color: const Color(0xffdee2e6)),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10, bottom: 10),
                                              child: SizedBox(
                                                width: 60,
                                                child: TextField(
                                                  controller:
                                                      _messageInputController_red,
                                                  decoration:
                                                      const InputDecoration(
                                                          border:
                                                              InputBorder.none),
                                                ),
                                              ),
                                            ),
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(right: 10),
                                              child: Text('s'),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 60,
                                        height: 30,
                                        decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Center(
                                          child: GestureDetector(
                                            onTap: () {
                                              Fluttertoast.showToast(
                                                  msg: "Time change complete",
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                  timeInSecForIosWeb: 3,
                                                  backgroundColor: Colors.blue,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0);
                                              stateDatas[selectTL - 1].rTime =
                                                  int.parse(
                                                      _messageInputController_red
                                                          .text);
                                            },
                                            child: const Text(
                                              'apply',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Container(
                            decoration:
                                const BoxDecoration(color: Color(0xfffbfbfb)),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Set the time remaining on the green light',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 35,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                                color: const Color(0xffdee2e6)),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10, bottom: 10),
                                              child: SizedBox(
                                                width: 60,
                                                child: TextField(
                                                  controller:
                                                      _messageInputController_green,
                                                  decoration:
                                                      const InputDecoration(
                                                          border:
                                                              InputBorder.none),
                                                ),
                                              ),
                                            ),
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(right: 10),
                                              child: Text('s'),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 60,
                                        height: 30,
                                        decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Center(
                                          child: GestureDetector(
                                            onTap: () {
                                              Fluttertoast.showToast(
                                                  msg: "Time change complete",
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                  timeInSecForIosWeb: 3,
                                                  backgroundColor: Colors.blue,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0);
                                              stateDatas[selectTL - 1].gTime =
                                                  int.parse(
                                                      _messageInputController_green
                                                          .text);
                                            },
                                            child: const Text(
                                              'apply',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Container(
                            decoration:
                                const BoxDecoration(color: Color(0xfffbfbfb)),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Average Crossing Time',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    selectInfo.avTime.toString(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
