import 'dart:io';

import 'package:flutter/material.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:relaxretail/Screens/Login.dart';
import 'package:relaxretail/Services/Authentication.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:relaxretail/Theme.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends StatefulWidget {
  final dynamic userId;
  final dynamic selectedDate;
  final dynamic role;
  const HomePage({super.key, this.userId, this.selectedDate, this.role});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> orderList = [];
  dynamic pdfData;
  bool showLoader = true;
  var pdf = pw.Document();
  dynamic beatName = "";
  DateTime now = DateTime.now();
  String formattedDate = "";
  String dwDate = "";
  dynamic font;
  late pw.MemoryImage memoryImage;
  double totalOrderUnit = 0.0;
  double totalOrderAmount = 0.0;
  double totalOfAllOrderUnit = 0.0;
  double totalOfAllOrderAmount = 0.0;
  DateTime selectedDate = DateTime.now();
  TextEditingController dateCOntroller = TextEditingController();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  bool isShared = false;
  bool workingSolo = false;
  dynamic tc;
  dynamic pc;
  dynamic workingWith;

  showLoaderDialog() {}

  getOrderFrpmApi() {
    getAttend(widget.userId).then((value) {
      if (value != null) {
        getDayworkProductivity(value['data'][0]['id']).then((value0) {
          tc = value0['data'][0]['totCalls'];
          pc = value0['data'][0]['totPc'];
          workingWith = value0['data'][0]['workWith'];
          if (value0['data'][0]['self'] == 'NO') {
            workingSolo = false;
          } else {
            workingSolo = true;
          }
        });
        getOrders(value['data'][0]['id']).then((value1) {
          totalOfAllOrderUnit = 0;
          totalOfAllOrderAmount = 0;
          if (value1 != "") {
            pdfData = value1;
            orderList = value1['data']['orders'];
            for (var i = 0; i < orderList.length; i++) {
              totalOrderUnit = 0.0;
              totalOrderAmount = 0.0;
              value1['data']['orders'][i]['totalOrderUnit'] = totalOrderUnit;
              value1['data']['orders'][i]['totalOrderAmount'] =
                  totalOrderAmount;
              for (var j = 0;
                  j < value1['data']['orders'][i]['products'].length;
                  j++) {
                totalOrderUnit = value1['data']['orders'][i]['products'][j]
                        ['pieces'] +
                    totalOrderUnit;
                totalOrderAmount = value1['data']['orders'][i]['products'][j]
                        ['amount'] +
                    totalOrderAmount;
                value1['data']['orders'][i]['totalOrderUnit'] = totalOrderUnit;
                value1['data']['orders'][i]['totalOrderAmount'] =
                    totalOrderAmount;
              }
              totalOfAllOrderUnit = totalOrderUnit + totalOfAllOrderUnit;
              totalOfAllOrderAmount = totalOrderAmount + totalOfAllOrderAmount;
              value1['data']['totalOfAllOrderUnit'] = totalOfAllOrderUnit;
              value1['data']['totalOfAllOrderAmount'] = totalOfAllOrderAmount;
            }
            beatName = pdfData['data']['custDesc'];
            dwDate =
                formatter.format(DateTime.parse(pdfData['data']['dwDate']));
            print(dwDate);
            showLoader = false;
            setState(() {});
          }
        });
      } else {
        showLoader = false;
        setState(() {});
      }
    });
  }

  callDateApiFunction(dynamic selectedDate) {
    getOrdersByDate(widget.userId, selectedDate).then((value) {
      if (value != null) {
        getDayworkProductivity(value['data'][0]['dayworkId']).then((value0) {
          tc = value0['data'][0]['totCalls'];
          pc = value0['data'][0]['totPc'];
          workingWith = value0['data'][0]['workWith'];
          if (value0['data'][0]['self'] == 'NO') {
            workingSolo = false;
          } else {
            workingSolo = true;
          }
        });
        getOrders(value['data'][0]['dayworkId']).then((value1) {
          totalOfAllOrderUnit = 0;
          totalOfAllOrderAmount = 0;
          if (value1 != null && value1 != "") {
            pdfData = value1;
            orderList = value1['data']['orders'];
            for (var i = 0; i < orderList.length; i++) {
              totalOrderUnit = 0.0;
              totalOrderAmount = 0.0;
              value1['data']['orders'][i]['totalOrderUnit'] = totalOrderUnit;
              value1['data']['orders'][i]['totalOrderAmount'] =
                  totalOrderAmount;
              for (var j = 0;
                  j < value1['data']['orders'][i]['products'].length;
                  j++) {
                totalOrderUnit = value1['data']['orders'][i]['products'][j]
                        ['pieces'] +
                    totalOrderUnit;
                totalOrderAmount = value1['data']['orders'][i]['products'][j]
                        ['amount'] +
                    totalOrderAmount;
                value1['data']['orders'][i]['totalOrderUnit'] = totalOrderUnit;
                value1['data']['orders'][i]['totalOrderAmount'] =
                    totalOrderAmount;
              }
              totalOfAllOrderUnit = totalOrderUnit + totalOfAllOrderUnit;
              totalOfAllOrderAmount = totalOrderAmount + totalOfAllOrderAmount;
              value1['data']['totalOfAllOrderUnit'] = totalOfAllOrderUnit;
              value1['data']['totalOfAllOrderAmount'] = totalOfAllOrderAmount;
            }
            beatName = pdfData['data']['custDesc'];
            dwDate =
                formatter.format(DateTime.parse(pdfData['data']['dwDate']));
            print(dwDate);
            showLoader = false;
            setState(() {});
          }
        });
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    String fomrattedDate = "";
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        showLoader = true;
        fomrattedDate = formatter.format(picked);
        dateCOntroller.text = fomrattedDate;
      });
      callDateApiFunction(fomrattedDate);
    }
  }

  Directory? directory;
  saveTempPdf() async {
    ShareResult shareResult;
    dynamic path = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS);
    final file = File("$path/$dwDate" + "_" + "$beatName" + ".pdf");
    if (await File("$path/$dwDate" + "_" + "$beatName" + ".pdf").exists()) {
      await File("$path/$dwDate" + "_" + "$beatName" + ".pdf").delete();
      file.writeAsBytes(await pdf.save());
      if (isShared) {
        XFile xfile = new XFile("$path/$dwDate" + "_" + "$beatName" + ".pdf");
        shareResult = await Share.shareXFiles([xfile], text: 'Great picture');
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => HomePage(
                      userId: widget.userId,
                      selectedDate: dateCOntroller.text,
                      role: widget.role,
                    )),
            (Route<dynamic> route) => false);
      }
      // ignore: use_build_context_synchronously
      if (!isShared) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => HomePage(
                      userId: widget.userId,
                      selectedDate: dateCOntroller.text,
                      role: widget.role,
                    )),
            (Route<dynamic> route) => false);
      }
    } else {
      file.writeAsBytes(await pdf.save());
      if (isShared) {
        XFile xfile = new XFile("$path/$dwDate" + "_" + "$beatName" + ".pdf");
        shareResult = await Share.shareXFiles([xfile], text: 'Great picture');
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => HomePage(
                      userId: widget.userId,
                      selectedDate: dateCOntroller.text,
                      role: widget.role,
                    )),
            (Route<dynamic> route) => false);
      }
      // ignore: use_build_context_synchronously
      if (!isShared) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => HomePage(
                      userId: widget.userId,
                      selectedDate: dateCOntroller.text,
                      role: widget.role,
                    )),
            (Route<dynamic> route) => false);
      }
    }
    if (!isShared) {
      Fluttertoast.showToast(
          msg: "Download Successfully",
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    }

    setState(() {});
  }

  dynamic _currentAddress;
  getAddressFromLatLng(dynamic latitude, dynamic longitude) async {
    await placemarkFromCoordinates(latitude, longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            "${place.street}, ${place.subLocality},${place.subAdministrativeArea}${place.postalCode}";
      });
      return _currentAddress;
    }).catchError((e) {
      debugPrint(e);
    });
  }

  getStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  getFonts() async {
    final imageByteData = await rootBundle.load('assets/images/rupee.png');
    final imageUint8List = imageByteData.buffer
        .asUint8List(imageByteData.offsetInBytes, imageByteData.lengthInBytes);

    memoryImage = pw.MemoryImage(imageUint8List);
  }

  @override
  void initState() {
    dateCOntroller.text = formatter.format(DateTime.now());
    if (widget.selectedDate != null) {
      callDateApiFunction(widget.selectedDate);
    } else {
      getOrderFrpmApi();
    }
    getFonts();
    formattedDate = DateFormat('dd').format(now);
    print(formattedDate);
    getStoragePermission();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: primaryColor,
            actions: [
              SizedBox(
                  width: MediaQuery.of(context).size.width * 1,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () {
                          getPdf();
                          isShared = true;
                          saveTempPdf();
                        },
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width * 0.06,
                            left: MediaQuery.of(context).size.width * 0.06,
                            top: 8,
                            bottom: 8,
                          ),
                          child: TextField(
                            controller: dateCOntroller,
                            readOnly: true,
                            onTap: () {
                              _selectDate(context);
                            },
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                  left: 20,
                                ),
                                fillColor: Colors.white,
                                filled: true,
                                hintText: "Select date",
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(18)))),
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Login()),
                                (route) => false);
                          },
                          icon: const Icon(Icons.logout))
                    ],
                  )),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: primaryColor,
            child: const Icon(Icons.download),
            onPressed: () {
              isShared = false;
              getPdf();
              saveTempPdf();
            },
          ),
          body: showLoader
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : showLoader == false && pdfData == null
                  ? const Center(
                      child: Text("No Attendence Found."),
                    )
                  : SafeArea(
                      child: Container(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.03,
                          left: MediaQuery.of(context).size.width * 0.04,
                          right: MediaQuery.of(context).size.width * 0.04,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Row(
                                  children: [
                                    const Text("Date : "),
                                    Text(
                                      formatter.format(DateTime.parse(
                                          pdfData['data']['dwDate'])),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                child: Row(
                                  children: [
                                    const Text("Beat : "),
                                    Text("${pdfData['data']['beatName']}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              Container(
                                child: Row(
                                  children: [
                                    const Text("Distributor Name : "),
                                    Text("${pdfData['data']['custDesc']}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              Container(
                                child: Row(
                                  children: [
                                    const Text(
                                      "Name : ",
                                    ),
                                    Text(
                                        "${widget.role} ${pdfData['data']['userName']}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              Container(
                                child: Row(
                                  children: [
                                    const Text(
                                      "Working : ",
                                    ),
                                    Text(
                                        workingSolo == false
                                            ? "Joint with $workingWith"
                                            : "Solo",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              Container(
                                child: Row(
                                  children: [
                                    const Text(
                                      "TC : ",
                                    ),
                                    Text(tc.toString(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              Container(
                                child: Row(
                                  children: [
                                    const Text(
                                      "PC : ",
                                    ),
                                    Text(pc.toString(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.03,
                              ),
                              ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: pdfData['data']['orders'].length,
                                  itemBuilder: (BuildContext context, int i) {
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                              child: Text(
                                                "Order Id : ${pdfData['data']['orders'][i]['orderId']}",
                                                style: const TextStyle(
                                                    fontSize: 19,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                            Container(
                                              child: Text(
                                                "Outlets Name : ${pdfData['data']['orders'][i]['shopName']}",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15),
                                              ),
                                            ),
                                            Container(
                                              child: Text(
                                                "Address  : ",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15),
                                              ),
                                            ),
                                            Container(
                                              child: Text(
                                                "Contact No  : ${pdfData['data']['orders'][i]['shopMobile']}",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10, top: 20),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      "Product",
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 15),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "Unit Price",
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 15),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "Pieces",
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 15),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "Amount",
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 15),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              1,
                                          child: ListView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: pdfData['data']
                                                      ['orders'][i]['products']
                                                  .length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10, bottom: 10),
                                                  decoration:
                                                      const BoxDecoration(
                                                          border: Border(
                                                              top: BorderSide(
                                                                  color: Colors
                                                                      .black,
                                                                  width: 1))),
                                                  child: Column(children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Container(
                                                            child: Text(
                                                              "${pdfData['data']['orders'][i]['products'][index]['fgDescription']}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          12),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            child: Text(
                                                              "₹ ${pdfData['data']['orders'][i]['products'][index]['price']}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          13),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            child: Text(
                                                                pdfData['data']['orders'][i]['products']
                                                                            [
                                                                            index]
                                                                        [
                                                                        'pieces']
                                                                    .toStringAsFixed(
                                                                        0),
                                                                textAlign:
                                                                    TextAlign
                                                                        .right,
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            13)),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            child: Text(
                                                              "₹ ${pdfData['data']['orders'][i]['products'][index]['amount']}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          13),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ]),
                                                );
                                              }),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Column(children: [
                                          Container(
                                            height: 1,
                                            color: Colors.black,
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "Total ",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(),
                                              ),
                                              Expanded(
                                                child: Text(
                                                    pdfData['data']['orders'][i]
                                                            ['totalOrderUnit']
                                                        .toStringAsFixed(0),
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                              Expanded(
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                    Text(
                                                        "₹ " +
                                                            pdfData['data'][
                                                                        'orders'][i]
                                                                    [
                                                                    'totalOrderAmount']
                                                                .toStringAsFixed(
                                                                    0),
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ]))
                                            ],
                                          ),
                                        ]),
                                        SizedBox(
                                          height: 40,
                                        ),
                                      ],
                                    );
                                  }),
                              Column(children: [
                                Row(
                                  children: [
                                    const Text("Total of all orders pieces : "),
                                    Text(
                                        pdfData['data']['totalOfAllOrderUnit']
                                            .toStringAsFixed(0),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    const Text("Total of all orders amount : "),
                                    Text(
                                        "₹ " +
                                            pdfData['data']
                                                    ['totalOfAllOrderAmount']
                                                .toStringAsFixed(0),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ]),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
    );
  }

  getPdf() {
    return pdf.addPage(pw.MultiPage(
        maxPages: 100,
        pageFormat:
            PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        build: (pw.Context context) => <pw.Widget>[
              pw.Container(
                child: pw.Row(
                  children: [
                    pw.Text("Date : ", style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(
                        formatter
                            .format(DateTime.parse(pdfData['data']['dwDate'])),
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  ],
                ),
              ),
              pw.Container(
                child: pw.Row(
                  children: [
                    pw.Text("Beat : ", style: const pw.TextStyle(fontSize: 10)),
                    pw.Text("${pdfData['data']['beatName']}",
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  ],
                ),
              ),
              pw.Container(
                child: pw.Row(
                  children: [
                    pw.Text("Distributor Name : ",
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.Text("${pdfData['data']['custDesc']}",
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  ],
                ),
              ),
              pw.Container(
                child: pw.Row(
                  children: [
                    pw.Text("Name : ",
                        style: const pw.TextStyle(
                          fontSize: 10,
                        )),
                    pw.Text("${widget.role} ${pdfData['data']['userName']}",
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
              pw.Container(
                child: pw.Row(
                  children: [
                    pw.Text("Working : ",
                        style: const pw.TextStyle(
                          fontSize: 10,
                        )),
                    pw.Text(
                        workingSolo == false
                            ? "Joint with $workingWith"
                            : "Solo",
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
              pw.Container(
                child: pw.Row(
                  children: [
                    pw.Text("TC : ",
                        style: const pw.TextStyle(
                          fontSize: 10,
                        )),
                    pw.Text(tc.toString(),
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
              pw.Container(
                child: pw.Row(
                  children: [
                    pw.Text("PC : ",
                        style: const pw.TextStyle(
                          fontSize: 10,
                        )),
                    pw.Text(pc.toString(),
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              for (var i = 0; i < pdfData['data']['orders'].length; i++)
                pw.Column(children: [
                  pw.Column(children: [
                    pw.Container(
                      child: pw.Text(
                        "Order Id : ${pdfData['data']['orders'][i]['orderId']}",
                        style: pw.TextStyle(
                            fontSize: 16, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Container(
                      child: pw.Text(
                        "Outlet Name : ${pdfData['data']['orders'][i]['shopName']}",
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    pw.Container(
                      child: pw.Text(
                        "Address  : ",
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    pw.Container(
                      child: pw.Text(
                        "Contact No  : ${pdfData['data']['orders'][i]['shopMobile']}",
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.only(bottom: 10, top: 20),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            child: pw.Text(
                              "Product",
                              textAlign: pw.TextAlign.left,
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              "Unit Price",
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              "Pieces",
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          pw.SizedBox(
                            width: 20,
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              "Amount",
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                  for (var index = 0;
                      index < pdfData['data']['orders'][i]['products'].length;
                      index++)
                    pw.Container(
                      height: 25,
                      decoration: const pw.BoxDecoration(
                          border: pw.Border(
                              top: pw.BorderSide(
                                  color: PdfColors.black, width: 1))),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                              child: pw.Align(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Container(
                                height: 25,
                                child: pw.Center(
                                  child: pw.Text(
                                    "${pdfData['data']['orders'][i]['products'][index]['fgDescription']}",
                                    textAlign: pw.TextAlign.left,
                                    style: const pw.TextStyle(fontSize: 7),
                                  ),
                                )),
                          )),
                          pw.Expanded(
                            child: pw.Container(
                              child: pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.end,
                                  children: [
                                    pw.SizedBox(
                                      height: 10,
                                      width: 10,
                                      child: pw.Image(memoryImage),
                                    ),
                                    pw.Text(
                                      " ${pdfData['data']['orders'][i]['products'][index]['price']}",
                                      textAlign: pw.TextAlign.right,
                                      style: const pw.TextStyle(fontSize: 9),
                                    ),
                                  ]),
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Container(
                              child: pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.end,
                                  children: [
                                    pw.Text(
                                      pdfData['data']['orders'][i]['products']
                                              [index]['pieces']
                                          .toStringAsFixed(0),
                                      textAlign: pw.TextAlign.right,
                                      style: const pw.TextStyle(fontSize: 9),
                                    ),
                                  ]),
                            ),
                          ),
                          pw.SizedBox(
                            width: 30,
                          ),
                          pw.Expanded(
                            child: pw.Container(
                                child: pw.Row(
                                    mainAxisAlignment: pw.MainAxisAlignment.end,
                                    children: [
                                  pw.SizedBox(
                                    height: 10,
                                    width: 10,
                                    child: pw.Image(memoryImage),
                                  ),
                                  pw.Text(
                                    " ${pdfData['data']['orders'][i]['products'][index]['amount']}",
                                    textAlign: pw.TextAlign.right,
                                    style: const pw.TextStyle(fontSize: 9),
                                  ),
                                ])),
                          ),
                        ],
                      ),
                    ),
                  pw.SizedBox(
                    height: 15,
                  ),
                  pw.Column(children: [
                    pw.Container(
                      height: 1,
                      color: PdfColors.black,
                    ),
                    pw.SizedBox(
                      height: 5,
                    ),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            "Total ",
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Container(),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                              pdfData['data']['orders'][i]['totalOrderUnit']
                                  .toStringAsFixed(0),
                              textAlign: pw.TextAlign.right,
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.SizedBox(
                          width: 30,
                        ),
                        pw.Expanded(
                            child: pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.end,
                                children: [
                              pw.SizedBox(
                                height: 10,
                                width: 10,
                                child: pw.Image(memoryImage),
                              ),
                              pw.Text(
                                  pdfData['data']['orders'][i]
                                          ['totalOrderAmount']
                                      .toStringAsFixed(0),
                                  textAlign: pw.TextAlign.right,
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                            ]))
                      ],
                    ),
                  ]),
                  pw.SizedBox(
                    height: 20,
                  ),
                ]),
              pw.Row(
                children: [
                  pw.Text("Total of all orders pieces : ",
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(
                      pdfData['data']['totalOfAllOrderUnit'].toStringAsFixed(0),
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ],
              ),
              pw.SizedBox(
                height: 5,
              ),
              pw.Row(
                children: [
                  pw.Text("Total of all orders amount : ",
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.SizedBox(
                    height: 10,
                    width: 10,
                    child: pw.Image(memoryImage),
                  ),
                  pw.Text(
                      " ${pdfData['data']['totalOfAllOrderAmount'].toStringAsFixed(0)}",
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ],
              ),
            ]));
  }
}
