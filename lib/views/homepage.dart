// lib/view/homepage.dart
import 'package:absen/constant/preference_handler.dart';
import 'package:absen/models/attendance_stats_model.dart'; // AttendanceStatistics
import 'package:absen/models/profile_model.dart';
import 'package:absen/service/absensi_api.dart';
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
  LatLng _currentPosition = const LatLng(-6.2000, 108.816666);
  String _currentAddress = "Mengambil lokasi...";
  Marker? _marker;
  bool isMapLoading = true;

  ProfileModel? profile;
  bool loading = true;

  // keep a Future for stats so refresh can re-run by changing this
  Future<AttendanceStatistics>? _statsFuture;

  @override
  void initState() {
    super.initState();
    loadUserName();
    getDataProfile();
    _getCurrentLocation();
    _loadStats();
  }

  Future<void> loadUserName() async {
    final savedName = await PreferenceHandler.getName();
    if (!mounted) return;
    setState(() {
      userName = savedName ?? "";
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
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

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentPosition = LatLng(position.latitude, position.longitude);

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final place = placemarks.isNotEmpty ? placemarks[0] : null;

      if (!mounted) return;
      setState(() {
        _currentAddress =
            "${place?.name ?? ''}${place?.street != null && place!.street!.isNotEmpty ? ', ${place.street}' : ''}, ${place?.locality ?? ''}, ${place?.country ?? ''}";

        _marker = Marker(
          markerId: const MarkerId("lokasi_saya"),
          position: _currentPosition,
          infoWindow: InfoWindow(
            title: "Lokasi Anda",
            snippet: _currentAddress,
          ),
        );

        isMapLoading = false;

        if (_googleMapController != null) {
          _googleMapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: _currentPosition, zoom: 16),
            ),
          );
        }
      });
    } catch (e) {
      // jika gagal ambil lokasi, tetap jangan crash
      if (!mounted) return;
      setState(() {
        isMapLoading = false;
        _currentAddress = "Gagal ambil lokasi";
      });
    }
  }

  Future<void> getDataProfile() async {
    final token = await PreferenceHandler.getToken(); // ambil token

    try {
      final data = await ApiService.getProfile(token);
      if (!mounted) return;
      setState(() {
        profile = data;
        userName = data.data?.name ?? "";
        loading = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print("Error: $e");
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  void _loadStats() {
    // simpan future supaya FutureBuilder tidak re-fetch kecuali kita panggil lagi
    setState(() {
      _statsFuture = AbsensiAPI.getStat();
    });
  }

  Future<void> _handleRefresh() async {
    // refresh stats + lokasi + profile
    _loadStats();
    await _getCurrentLocation();
    await getDataProfile();
    // tunggu sedikit biar UI smooth (opsional)
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Widget _buildStatsCard() {
    return FutureBuilder<AttendanceStatistics>(
      future: _statsFuture,
      builder: (context, snapshot) {
        // loading kecil untuk tile
        if (snapshot.connectionState == ConnectionState.waiting &&
            snapshot.data == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text("Memuat statistik..."),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Column(
            children: [
              _statsHeaderPlaceholder(),
              const SizedBox(height: 8),
              Text(
                "Gagal memuat statistik: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 8),
            ],
          );
        }

        if (!snapshot.hasData) {
          return Column(
            children: [
              _statsHeaderPlaceholder(),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadStats,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: const Text("Refresh Statistik"),
              ),
            ],
          );
        }

        final stats = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header small
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Statistik Absen",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  onPressed: _loadStats,
                  icon: const Icon(Icons.refresh),
                  tooltip: "Refresh statistik",
                ),
              ],
            ),

            const SizedBox(height: 8),

            // tiles
            Row(
              children: [
                _statTile(
                  Icons.calendar_today_outlined,
                  "Total Absen",
                  stats.totalAbsen.toString(),
                  Colors.black,
                ),
                const SizedBox(width: 10),
                _statTile(
                  Icons.login,
                  "Masuk",
                  stats.totalMasuk.toString(),
                  Colors.green,
                ),
                const SizedBox(width: 10),
                _statTile(
                  Icons.event_busy,
                  "Izin",
                  stats.totalIzin.toString(),
                  Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 14),

            // today's status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: stats.sudahAbsenHariIni
                    ? Colors.green.withOpacity(0.08)
                    : Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: [
                  Icon(
                    stats.sudahAbsenHariIni ? Icons.check_circle : Icons.info,
                    color: stats.sudahAbsenHariIni
                        ? Colors.green
                        : Colors.orange,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      stats.sudahAbsenHariIni
                          ? "Sudah absen hari ini"
                          : "Belum absen hari ini",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: stats.sudahAbsenHariIni
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _loadStats,
                    child: const Text(
                      "Lihat detail",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _statsHeaderPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: const Text(
        "Statistik absen",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _statTile(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(label, style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapCard() {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.white),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: isMapLoading
            ? const Center(child: CircularProgressIndicator())
            : GoogleMap(
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
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              // Check In logic (tetap ada)
              String? token = await PreferenceHandler.getToken();
              if (token == null || token.isEmpty) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Token tidak ditemukan, login ulang!"),
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
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result.message ?? "Berhasil Check In"),
                  ),
                );
                _loadStats();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Check In gagal: $e")));
              }
            },
            icon: const Icon(Icons.login, color: Colors.white),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text("Check In", style: TextStyle(color: Colors.white)),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              // Check Out logic (tetap ada)
              String? token = await PreferenceHandler.getToken();
              if (token == null || token.isEmpty) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Token tidak ditemukan, login ulang!"),
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
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result.message ?? "Berhasil Check Out"),
                  ),
                );
                _loadStats();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Check Out gagal: $e")));
              }
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text("Check Out", style: TextStyle(color: Colors.white)),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String today = DateFormat(
      "EEEE, dd MMMM yyyy",
      "en_US",
    ).format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF1F3551), Color(0xFFBFD9E8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white24,
                            child: Text(
                              userName.isNotEmpty
                                  ? userName[0].toUpperCase()
                                  : "",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hello, $userName",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  today,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _handleRefresh,
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // map section
                    const Text(
                      "Your Location",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildMapCard(),
                    const SizedBox(height: 10),
                    Text(
                      _currentAddress,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // stats
                    _buildStatsCard(),

                    const SizedBox(height: 16),

                    // action buttons
                    _buildActionButtons(),

                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
    );
  }
}
