import 'dart:convert';
import 'dart:developer';

import 'package:absen/constant/endpoint.dart';
import 'package:absen/constant/preference_handler.dart';
import 'package:absen/models/attedence_models.dart';
import 'package:absen/models/attendance_stats_model.dart';
import 'package:absen/models/batch_model.dart';
import 'package:absen/models/checkin_model.dart';
import 'package:absen/models/checkout_model.dart';
import 'package:absen/models/login_model.dart';
import 'package:absen/models/profile_model.dart';
import 'package:absen/models/register_model.dart';
import 'package:absen/models/training_model.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthAPI {
  static Future<RegisterModel> registerUser({
    required String email,
    required String name,
    required String password,
    required String jenisKelamin, // 'L' / 'P'
    required int batchId,
    required int trainingId,
    String profilePhoto = "", // sementara kosong
  }) async {
    final url = Uri.parse(Endpoint.register);
    final response = await http.post(
      url,
      headers: {"Accept": "application/json"},
      body: {
        "name": name,
        "email": email,
        "password": password,
        "jenis_kelamin": jenisKelamin,
        "profile_photo": profilePhoto,
        "batch_id": batchId.toString(),
        "training_id": trainingId.toString(),
      },
    );

    log(response.body);
    log('status: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return RegisterModel.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Terjadi kesalahan");
    }
  }

  static Future<LoginModel> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(Endpoint.login);

    final response = await http.post(
      url,
      headers: {"Accept": "application/json"},
      body: {"email": email, "password": password},
    );

    log("LOGIN STATUS: ${response.statusCode}");
    log("LOGIN BODY: ${response.body}");

    final res = LoginModel.fromJson(json.decode(response.body));

    if (response.statusCode == 200) {
      // Simpan token
      await PreferenceHandler.saveToken(res.data?.token ?? "");

      // Simpan nama user
      await PreferenceHandler.saveName(res.data?.user?.name ?? "");

      return res;
    } else {
      throw Exception(res.message ?? "Login gagal");
    }
  }
}

class TrainingAPI {
  static Future<List<TrainingModelData>> getTrainings() async {
    final url = Uri.parse(Endpoint.trainings);
    final response = await http.get(
      url,
      headers: {"Accept": "application/json"},
    );

    log('getTrainings: ${response.statusCode}');
    log(response.body);

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final List data = jsonBody['data'] as List;
      return data.map((e) => TrainingModelData.fromJson(e)).toList();
    } else {
      throw Exception("Gagal mengambil data pelatihan");
    }
  }

  static Future<List<BatchModelData>> getTrainingBatches() async {
    final url = Uri.parse(Endpoint.trainingBatches);
    final response = await http.get(
      url,
      headers: {"Accept": "application/json"},
    );

    log('getTrainingBatches: ${response.statusCode}');
    log(response.body);

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final List data = jsonBody['data'] as List;
      return data.map((e) => BatchModelData.fromJson(e)).toList();
    } else {
      throw Exception("Gagal mengambil data batch pelatihan");
    }
  }
}

class ApiService {
  static const String baseUrl = "https://appabsensi.mobileprojp.com/api";

  static Future<ProfileModel> getProfile(String token) async {
    final response = await http.get(
      Uri.parse(Endpoint.profile),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );
    print(response.body);

    if (response.statusCode == 200) {
      return ProfileModel.fromJson(json.decode(response.body));
    } else {
      throw Exception("Gagal mengambil data profile");
    }
  }
}

class CheckInAPI {
  static Future<CheckInModel> checkIn({
    required String token,
    required double lat,
    required double lng,
    required String location,
    required String address,
  }) async {
    final url = Uri.parse(Endpoint.checkIn);

    final body = {
      "attendance_date": DateFormat("yyyy-MM-dd").format(DateTime.now()),
      "check_in": DateFormat("HH:mm").format(DateTime.now()),
      "check_in_lat": lat.toString(),
      "check_in_lng": lng.toString(),
      "check_in_location": location,
      "check_in_address": address,
    };

    log("CHECK IN SEND: $body");

    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Bearer $token",
      },
      body: body,
    );

    log("CHECK IN STATUS: ${response.statusCode}");
    log("CHECK IN BODY: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CheckInModel.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Gagal Check In");
    }
  }
}

class CheckOutAPI {
  static Future<CheckOutModel> checkOut({
    required String token,
    required double lat,
    required double lng,
    required String location,
    required String address,
  }) async {
    final url = Uri.parse(Endpoint.checkOut);

    final body = {
      "attendance_date": DateFormat("yyyy-MM-dd").format(DateTime.now()),
      "check_out": DateFormat("HH:mm").format(DateTime.now()),
      "check_out_lat": lat.toString(),
      "check_out_lng": lng.toString(),
      "check_out_location": location,
      "check_out_address": address,
    };

    log("CHECK OUT SEND: $body");

    final response = await http.post(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
      body: body,
    );

    log("CHECK OUT STATUS: ${response.statusCode}");
    log("CHECK OUT BODY: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CheckOutModel.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Gagal Check Out");
    }
  }
}

class ProfileService {
  // Mengembalikan true kalau berhasil (HTTP 2xx), false kalau gagal
  static Future<bool> updateProfile(String newName) async {
    // Dapatkan token secara asynchronous
    final token = await PreferenceHandler.getToken();

    // cek token null/empty
    if (token == null || token.isEmpty) {
      print('updateProfile: token kosong');
      return false;
    }

    // Gunakan Endpoint.profile agar path selalu konsisten
    final uri = Uri.parse(
      Endpoint.profile,
    ); // pastikan Endpoint.profile = 'https://.../api/profile'

    final response = await http.put(
      uri,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Bearer $token",
      },
      body: {"name": newName},
    );

    print("STATUS: ${response.statusCode}");
    print("RESPONSE: ${response.body}");

    // treat any 2xx as success
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  // (Opsi) versi yang mengembalikan response body / ProfileModel
  static Future<Map<String, dynamic>> updateProfileWithDetail(
    String newName,
  ) async {
    final token = await PreferenceHandler.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan');
    }
    final uri = Uri.parse(Endpoint.profile);
    final response = await http.put(
      uri,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Bearer $token",
      },
      body: {"name": newName},
    );

    print("STATUS: ${response.statusCode}");
    print("RESPONSE: ${response.body}");

    final body = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body; // caller bisa parse jadi ProfileModel jika perlu
    } else {
      // ambil pesan detail bila ada
      final msg = body is Map
          ? (body['message'] ?? body['errors'] ?? response.body)
          : response.body;
      throw Exception(msg.toString());
    }
  }

  static Future<AttendanceStatistics> getStats() async {
    final url = Uri.parse(
      Endpoint.statistik,
    ); // pastikan Endpoint.statistik benar
    final token = await PreferenceHandler.getToken();

    final res = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      final jsonBody = jsonDecode(res.body);
      // Pastikan DataAttend.fromJson menangani struktur JSON
      return AttendanceStatistics.fromJson(jsonBody);
    } else {
      throw Exception(
        'Failed to load attendance stats: ${res.statusCode} ${res.body}',
      );
    }
  }
}
