import 'package:absen/models/attedence_models.dart';
import 'package:absen/service/absensi_api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  bool loading = true;
  List<DataAttend> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final res = await AbsensiAPI.getHistory();

      /// Sort: terbaru → terlama
      res.sort((a, b) {
        final ad = a.attendanceDate ?? '';
        final bd = b.attendanceDate ?? '';
        return bd.compareTo(ad);
      });

      setState(() {
        history = res;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat("yyyy-MM-dd").format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "History Absensi",
          style: TextStyle(color: Colors.black),
        ),
        automaticallyImplyLeading: false,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : history.isEmpty
          ? const Center(
              child: Text(
                "Belum ada riwayat absensi",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];

                final date = formatDate(item.attendanceDate);
                final checkIn = item.checkInTime ?? "-";
                final checkOut = item.checkOutTime ?? "-";
                final status = item.status ?? "-";

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black),
                    boxShadow: const [
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
                      // Tanggal
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          infoColumn("Check In", checkIn),
                          infoColumn("Check Out", checkOut),
                          statusBox(status),
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
        Text(
          title,
          style: const TextStyle(color: Colors.black54, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget statusBox(String status) {
    Color statusColor;

    switch (status.toLowerCase()) {
      case "hadir":
        statusColor = Colors.green;
        break;
      case "izin":
        statusColor = Colors.orange;
        break;
      case "alpha":
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.blueGrey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
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
