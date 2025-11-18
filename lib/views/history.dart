import 'package:flutter/material.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  bool loading = true;

  // Contoh dummy data (nanti bisa diganti API)
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    await Future.delayed(Duration(seconds: 1));

    // Nanti ini diganti API history kamu
    history = [
      {
        "date": "2025-02-10",
        "check_in": "08:12",
        "check_out": "17:01",
        "status": "Hadir",
      },
      {
        "date": "2025-02-09",
        "check_in": "08:45",
        "check_out": "17:10",
        "status": "Hadir",
      },
      {
        "date": "2025-02-08",
        "check_in": "-",
        "check_out": "-",
        "status": "Izin",
      },
    ];

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("History Absensi", style: TextStyle(color: Colors.black)),
        automaticallyImplyLeading: false,
      ),

      body: loading
          ? Center(child: CircularProgressIndicator(color: Colors.black))
          : ListView.builder(
              padding: EdgeInsets.all(20),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];

                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date
                      Text(
                        item["date"],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          infoColumn("Check In", item["check_in"]),
                          infoColumn("Check Out", item["check_out"]),
                          statusBox(item["status"]),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget infoColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Colors.black54, fontSize: 13)),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget statusBox(String status) {
    Color statusColor = status == "Hadir" ? Colors.green : Colors.orange;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: statusColor.withOpacity(0.15),
        border: Border.all(color: statusColor),
      ),
      child: Text(
        status,
        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}
