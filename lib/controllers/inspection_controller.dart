import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InspectionController extends GetxController {
  final nopolController = TextEditingController();
  final kmController = TextEditingController();
  final alamatController = TextEditingController();
  final alasanController = TextEditingController();
  final catatanController = TextEditingController();

  final eksterior = RxnString();
  final mesin = RxnString();
  final bisaDipindahkan = RxnString();
  
  final gpsLat = RxnDouble();
  final gpsLng = RxnDouble();
  final isGpsLoading = false.obs;

  final photos = <String, Map<String, dynamic>?>{
    'Depan': null,
    'Belakang': null,
    'Kiri': null,
    'Kanan': null,
    'Speedometer': null,
  }.obs;

  final signaturePoints = <Offset?>[].obs;

  final isDebtorVerified = false.obs;
  final debtorVerificationMessage = "BELUM VERIFIKASI WAJAH".obs;

  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    _loadAutosaveData();

    nopolController.addListener(_onTextChanged);
    kmController.addListener(_onTextChanged);
    alamatController.addListener(_onTextChanged);
    alasanController.addListener(_onTextChanged);
    catatanController.addListener(_onTextChanged);

    ever(eksterior, (_) => _saveToLocalStorage());
    ever(mesin, (_) => _saveToLocalStorage());
    ever(bisaDipindahkan, (_) => _saveToLocalStorage());
    ever(photos, (_) => _saveToLocalStorage());
    ever(signaturePoints, (_) => _saveToLocalStorage());
    ever(isDebtorVerified, (_) => _saveToLocalStorage());
  }

  @override
  void onClose() {
    nopolController.dispose();
    kmController.dispose();
    alamatController.dispose();
    alasanController.dispose();
    catatanController.dispose();
    _debounceTimer?.cancel();
    super.onClose();
  }

  void _onTextChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _saveToLocalStorage();
    });
  }

  Future<void> _loadAutosaveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString('autosave_inspection');
      if (dataStr != null) {
        final Map<String, dynamic> data = jsonDecode(dataStr);
        
        nopolController.text = data['nopol'] ?? '';
        kmController.text = data['km'] ?? '';
        alamatController.text = data['alamat'] ?? '';
        alasanController.text = data['alasan'] ?? '';
        catatanController.text = data['catatan'] ?? '';
        
        eksterior.value = data['eksterior'];
        mesin.value = data['mesin'];
        bisaDipindahkan.value = data['bisa_dipindahkan'];
        
        if (data['gps_lat'] != null) gpsLat.value = data['gps_lat'];
        if (data['gps_lng'] != null) gpsLng.value = data['gps_lng'];
        
        if (data['photos'] != null) {
          photos.value = Map<String, Map<String, dynamic>?>.from(
            (data['photos'] as Map).map(
              (k, v) => MapEntry(k as String, v != null ? Map<String, dynamic>.from(v) : null),
            ),
          );
        }

        if (data['signature'] != null) {
          final List list = data['signature'];
          signaturePoints.value = list.map((item) {
            if (item == null) return null;
            return Offset((item['x'] as num).toDouble(), (item['y'] as num).toDouble());
          }).toList();
        }

        isDebtorVerified.value = data['debtor_verified'] ?? false;
        debtorVerificationMessage.value = data['debtor_message'] ?? "BELUM VERIFIKASI WAJAH";
      }
    } catch (e) {
      // Ignored
    }
  }

  Future<void> _saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final List<Map<String, double>?> serializedSignature = signaturePoints.map((p) {
        if (p == null) return null;
        return {'x': p.dx, 'y': p.dy};
      }).toList();

      final Map<String, dynamic> data = {
        'nopol': nopolController.text,
        'km': kmController.text,
        'alamat': alamatController.text,
        'alasan': alasanController.text,
        'catatan': catatanController.text,
        'eksterior': eksterior.value,
        'mesin': mesin.value,
        'bisa_dipindahkan': bisaDipindahkan.value,
        'gps_lat': gpsLat.value,
        'gps_lng': gpsLng.value,
        'photos': photos,
        'signature': serializedSignature,
        'debtor_verified': isDebtorVerified.value,
        'debtor_message': debtorVerificationMessage.value,
      };

      await prefs.setString('autosave_inspection', jsonEncode(data));
    } catch (e) {
      // Ignored
    }
  }

  void getGPSLocation() {
    isGpsLoading.value = true;
    
    Future.delayed(const Duration(milliseconds: 800), () {
      gpsLat.value = -6.175392 + (Random().nextDouble() - 0.5) * 0.01;
      gpsLng.value = 106.827153 + (Random().nextDouble() - 0.5) * 0.01;
      isGpsLoading.value = false;
      _saveToLocalStorage();
    });
  }

  void capturePhoto(String sideName) {
    final now = DateTime.now();
    final mockLat = -6.175392 + (Random().nextDouble() - 0.5) * 0.01;
    final mockLng = 106.827153 + (Random().nextDouble() - 0.5) * 0.01;
    
    var updatedPhotos = Map<String, Map<String, dynamic>?>.from(photos);
    updatedPhotos[sideName] = {
      'path': 'mock_path_$sideName.jpg',
      'timestamp': now.toIso8601String(),
      'lat': mockLat,
      'lng': mockLng,
      'surveyor': 'Budi Santoso (ID: 998)',
    };
    photos.value = updatedPhotos;
  }

  void setEksterior(String? val) => eksterior.value = val;
  void setMesin(String? val) => mesin.value = val;
  
  void setBisaDipindahkan(String? val) {
    bisaDipindahkan.value = val;
    if (val != 'Tidak') {
      alasanController.clear();
    }
  }

  void addSignaturePoint(Offset? point) {
    signaturePoints.add(point);
  }

  void clearSignature() {
    signaturePoints.clear();
  }

  void failFaceMatch() {
    isDebtorVerified.value = false;
    debtorVerificationMessage.value = "ERROR: API Timeout 504 - Face Matcher Server is offline";
  }

  void bypassFaceMatch() {
    isDebtorVerified.value = true;
    debtorVerificationMessage.value = "BYPASS MANUAL OLEH SURVEYOR (MOCK VERIFIED)";
  }

  void submitInspection(BuildContext context, GlobalKey<FormState> formKey) {
    if (!formKey.currentState!.validate()) {
      return;
    }

    for (var key in photos.keys) {
      if (photos[key] == null) {
        Get.snackbar(
          "Validasi Gagal", 
          "Foto $key wajib diambil!",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    if (signaturePoints.isEmpty) {
      Get.snackbar(
        "Validasi Gagal", 
        "Tanda tangan wajib diisi!",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text("Data Terkirim"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Data inspeksi berhasil disubmit ke server!"),
              const SizedBox(height: 10),
              const Text("Payload Foto & Metadata:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(const JsonEncoder.withIndent('  ').convert({
                'nopol': nopolController.text,
                'km': int.tryParse(kmController.text) ?? 0,
                'alamat': alamatController.text,
                'eksterior': eksterior.value,
                'mesin': mesin.value,
                'bisa_dipindahkan': bisaDipindahkan.value,
                'alasan_tidak_pindah': alasanController.text,
                'catatan': catatanController.text,
                'gps_inspeksi': {'lat': gpsLat.value, 'lng': gpsLng.value},
                'photos_metadata': photos,
                'signature_points_count': signaturePoints.where((p) => p != null).length,
                'debtor_verification': {
                  'status': isDebtorVerified.value ? "VERIFIED" : "FAILED_OR_BYPASS",
                  'details': debtorVerificationMessage.value,
                }
              })),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              SharedPreferences.getInstance().then((prefs) {
                prefs.remove('autosave_inspection');
              });
              
              nopolController.clear();
              kmController.clear();
              alamatController.clear();
              alasanController.clear();
              catatanController.clear();
              
              eksterior.value = null;
              mesin.value = null;
              bisaDipindahkan.value = null;
              
              gpsLat.value = null;
              gpsLng.value = null;
              
              photos.value = {
                'Depan': null,
                'Belakang': null,
                'Kiri': null,
                'Kanan': null,
                'Speedometer': null,
              };
              signaturePoints.clear();
              isDebtorVerified.value = false;
              debtorVerificationMessage.value = "BELUM VERIFIKASI WAJAH";

              Get.back();
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }
}
