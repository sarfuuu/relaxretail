import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:relaxretail/Screens/Login.dart';
import 'package:relaxretail/Services/Authentication.dart';
import 'package:relaxretail/Theme.dart';

class Report extends StatefulWidget {
  final dynamic userId;
  final dynamic selectedDate;
  final dynamic role;
  const Report({super.key, this.userId, this.selectedDate, this.role});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  TextEditingController dateCOntroller = TextEditingController();
  DateTime selectedDate = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  List<dynamic> reportList = [];
  bool refresh = true;

  Future<void> _selectDate(BuildContext context) async {
    String fomrattedDate = "";
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      fomrattedDate = formatter.format(picked);
      dateCOntroller.text = fomrattedDate;
      refresh = true;
      getReport(dateCOntroller.text);
      setState(() {});
    }
  }

  getReport(dynamic formattedDate) async {
    getReportByDate(formattedDate).then((value) {
      if (value != null) {
        reportList = value['data'];
      }
      refresh = false;
      setState(() {});
    });
  }

  @override
  void initState() {
    dateCOntroller.text = formatter.format(selectedDate);
    getReport(dateCOntroller.text);
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
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(18)))),
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
            body: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.015,
                    top: MediaQuery.of(context).size.height * 0.015,
                    right: MediaQuery.of(context).size.width * 0.04,
                    left: MediaQuery.of(context).size.width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (reportList.isEmpty)
                      Container(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.4),
                        child: const Center(
                          child: Text("Record not found."),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "ATTENDANCE LIST",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "Date - ${dateCOntroller.text}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            // ignore: prefer_const_literals_to_create_immutables
                            children: [
                              const Expanded(
                                child: Text(
                                  "User Name",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              const Expanded(
                                child: Text(
                                  "Code",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              const Expanded(
                                child: Text(
                                  "Status",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              const Expanded(
                                child: Text(
                                  "Working",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            height: 1,
                            color: Colors.black,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: reportList.length,
                              itemBuilder: (BuildContext context, int i) {
                                return Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      // ignore: prefer_const_literals_to_create_immutables
                                      children: [
                                        Expanded(
                                          child: Text(
                                            reportList[i]['userName'],
                                            style:
                                                const TextStyle(fontSize: 13),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            reportList[i]['userSapId']
                                                .toString(),
                                            textAlign: TextAlign.center,
                                            style:
                                                const TextStyle(fontSize: 13),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            reportList[i]['status'],
                                            textAlign: TextAlign.center,
                                            style:
                                                const TextStyle(fontSize: 13),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            reportList[i]['workwith'],
                                            style:
                                                const TextStyle(fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                  ],
                                );
                              })
                        ],
                      ),
                  ],
                ),
              ),
            )));
  }
}
