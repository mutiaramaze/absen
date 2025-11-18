import 'dart:convert';
import 'dart:developer';

import 'package:absen/constant/endpoint.dart';
import 'package:absen/models/batch_model.dart';
import 'package:absen/models/checkin_model.dart';
import 'package:absen/models/checkout_model.dart';
import 'package:absen/models/profile_model.dart';
import 'package:absen/models/register_model.dart';
import 'package:absen/models/training_model.dart';
import 'package:http/http.dart' as http;

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
  static const String baseUrl = "https://absensib1.mobileprojp.com/api";

  static Future<ProfileModel> getProfile(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/profile"),
      headers: {"Authorization": "Bearer $token"},
    );

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

    final response = await http.post(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
      body: {
        "check_in_lat": lat.toString(),
        "check_in_lng": lng.toString(),
        "check_in_location": location,
        "check_in_address": address,
      },
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

    final response = await http.post(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
      body: {
        "check_out_lat": lat.toString(),
        "check_out_lng": lng.toString(),
        "check_out_location": location,
        "check_out_address": address,
      },
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
