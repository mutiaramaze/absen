import 'dart:convert';
import 'dart:developer';

import 'package:absen/constant/endpoint.dart';
import 'package:absen/models/batch_model.dart';
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
