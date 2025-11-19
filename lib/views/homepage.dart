import 'package:absen/constant/preference_handler.dart';
import 'package:absen/models/profile_model.dart';
import 'package:absen/service/api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});
  static const id = "/checkin";

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String userName = "";
  GoogleMapController? _googleMapController;
  LatLng _currentPosition = LatLng(-6.2000, 108.816666);
  String _currentAddress = "Mengambil lokasi...";
  Marker? _marker;
  bool isMapLoading = true;

  ProfileModel? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadUserName();
    getDataProfile();
    _getCurrentLocation();
  }

  Future<void> loadUserName() async {
    String? savedName = await PreferenceHandler.getName();
    setState(() {
      userName = savedName ?? "";
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _currentPosition = LatLng(position.latitude, position.longitude);

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    Placemark place = placemarks[0];

    setState(() {
      _currentAddress =
          "${place.name}, ${place.street}, ${place.locality}, ${place.country}";

      _marker = Marker(
        markerId: MarkerId("lokasi_saya"),
        position: _currentPosition,
        infoWindow: InfoWindow(title: "Lokasi Anda", snippet: _currentAddress),
      );

      isMapLoading = false;

      _googleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition, zoom: 16),
        ),
      );
    });
  }

  Future<void> getDataProfile() async {
    String token =
        await PreferenceHandler.getToken(); // TODO: ambil dari SharedPreferences

    try {
      final data = await ApiService.getProfile(token);
      print('data: ${data.data!.name}');
      setState(() {
        profile = data;
        userName = data.data!.name!;
        loading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String today = DateFormat(
      "EEEE, dd MMMM yyyy",
      "en_US",
    ).format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello, $userName",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            today,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    Text(
                      "Lokasi Anda",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),

                    Container(
                      height: 350,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isMapLoading
                          ? Center(child: CircularProgressIndicator())
                          : Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: GoogleMap(
                                  myLocationEnabled: true,
                                  markers: _marker != null ? {_marker!} : {},
                                  initialCameraPosition: CameraPosition(
                                    target: _currentPosition,
                                    zoom: 15,
                                  ),
                                  onMapCreated: (controller) {
                                    _googleMapController = controller;
                                  },
                                ),
                              ),
                            ),
                    ),

                    SizedBox(height: 10),

                    Text(_currentAddress, style: TextStyle(fontSize: 16)),

                    SizedBox(height: 10),

                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                        ),
                        onPressed: _getCurrentLocation,
                        child: Text("Refresh Lokasi"),
                      ),
                    ),

                    SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              print("Check In ditekan");

                              String? token =
                                  await PreferenceHandler.getToken();

                              if (token == null || token.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Token tidak ditemukan, login ulang!",
                                    ),
                                  ),
                                );
                                return;
                              }

                              try {
                                final result = await CheckInAPI.checkIn(
                                  token: token,
                                  lat: _currentPosition.latitude,
                                  lng: _currentPosition.longitude,
                                  location: "Lokasi Pengguna",
                                  address: _currentAddress,
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      result.message ?? "Berhasil Check In",
                                    ),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Check In gagal: $e")),
                                );
                              }
                            },

                            child: Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Check In",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 16),

                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              print("Check Out ditekan");

                              String? token =
                                  await PreferenceHandler.getToken();

                              if (token == null || token.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Token tidak ditemukan, login ulang!",
                                    ),
                                  ),
                                );
                                return;
                              }

                              try {
                                final result = await CheckOutAPI.checkOut(
                                  token: token,
                                  lat: _currentPosition.latitude,
                                  lng: _currentPosition.longitude,
                                  location: "Lokasi Pengguna",
                                  address: _currentAddress,
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      result.message ?? "Berhasil Check Out",
                                    ),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Check Out gagal: $e"),
                                  ),
                                );
                              }
                            },

                            child: Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Check Out",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
