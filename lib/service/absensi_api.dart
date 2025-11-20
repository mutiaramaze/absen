import 'dart:convert';
import 'dart:developer';
import 'package:absen/constant/preference_handler.dart';
import 'package:absen/models/attedence_models.dart'; // must contain AttendanceStats, AttendanceData, and DataAttend (history)
import 'package:absen/models/attendance_stats_model.dart';
import 'package:absen/models/user_models.dart';
import 'package:http/http.dart' as http;

class AbsensiAPI {
  static const String baseUrl = "https://appabsensi.mobileprojp.com/api";

  // HEADER TOKEN
  static Future<Map<String, String>> _headers() async {
    final token = await PreferenceHandler.getToken();
    return {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
      "Content-Type": "application/json",
    };
  }

  // GET (raw)
  static Future<dynamic> _get(String endpoint) async {
    final headers = await _headers();
    final url = "$baseUrl$endpoint";

    final res = await http.get(Uri.parse(url), headers: headers);

    log("GET → $url");
    log("STATUS → ${res.statusCode}");

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      // pastikan body decode aman
      try {
        final err = jsonDecode(res.body);
        throw Exception(err["message"] ?? res.body);
      } catch (_) {
        throw Exception("Request failed: ${res.statusCode}");
      }
    }
  }

  // POST (raw)
  static Future<dynamic> _post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final headers = await _headers();
    final url = "$baseUrl$endpoint";

    final res = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    log("POST → $url");
    log("DATA → $body");
    log("STATUS → ${res.statusCode}");
    log("BODY → ${res.body}");

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body);
    } else {
      try {
        final err = jsonDecode(res.body);
        throw Exception(err["message"] ?? res.body);
      } catch (_) {
        throw Exception("Request failed: ${res.statusCode}");
      }
    }
  }

  // ================== STATISTIK ==================
  /// Mengembalikan AttendanceStats (wrapper: message + data)
  static Future<AttendanceStatistics> getStat() async {
    final jsonBody = await _get('/absen/stats');
    // pastikan jsonBody adalah Map<String, dynamic>
    return AttendanceStatistics.fromJson(jsonBody as Map<String, dynamic>);
  }

  // PROFILE
  static Future<GetUserModel> getProfile() async {
    final token = await PreferenceHandler.getToken();

    final res = await http.get(
      Uri.parse("$baseUrl/profile"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (res.statusCode == 200) {
      return GetUserModel.fromJson(jsonDecode(res.body));
    } else {
      try {
        final err = jsonDecode(res.body);
        throw Exception(err["message"] ?? res.body);
      } catch (_) {
        throw Exception("Gagal mengambil profil: ${res.statusCode}");
      }
    }
  }

  // CHECK IN
  // tetap mengembalikan DataAttend (history/check-in model)
  static Future<DataAttend> checkIn({
    required String attendanceDate,
    required String time,
    required double lat,
    required double lng,
    required String address,
  }) async {
    final res = await _post("/absen/check-in", {
      "attendance_date": attendanceDate,
      "check_in": time,
      "check_in_lat": lat,
      "check_in_lng": lng,
      "check_in_address": address,
    });

    // res diharapkan berupa root JSON: { "message": "...", "data": { ... } }
    // Jika API mengembalikan record detail di "data", pass data ke DataAttend.fromJson
    final payload = res is Map<String, dynamic> && res["data"] != null
        ? res["data"]
        : res;
    return DataAttend.fromJson(payload as Map<String, dynamic>);
  }

  // CHECK OUT
  static Future<DataAttend> checkOut({
    required String attendanceDate,
    required String time,
    required double lat,
    required double lng,
    required String address,
  }) async {
    final res = await _post("/absen/check-out", {
      "attendance_date": attendanceDate,
      "check_out": time,
      "check_out_lat": lat,
      "check_out_lng": lng,
      "check_out_address": address,
      "check_out_location": "$lat,$lng",
    });

    final payload = res is Map<String, dynamic> && res["data"] != null
        ? res["data"]
        : res;
    return DataAttend.fromJson(payload as Map<String, dynamic>);
  }

  // HISTORY
  static Future<List<DataAttend>> getHistory() async {
    final data = await _get("/absen/history");
    final List list = data["data"] ?? [];

    return list
        .map((e) => DataAttend.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // EDIT PROFILE
  static Future<dynamic> editProfile({
    required String name,
    required String email,
  }) async {
    return _post("/edit-profile", {"name": name, "email": email});
  }
}
