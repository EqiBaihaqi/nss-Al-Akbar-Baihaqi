import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/inspection_controller.dart';
import 'widgets/camera_simulator_dialog.dart';
import 'widgets/face_verification_box.dart';
import 'widgets/signature_canvas.dart';

class InspectionFormScreen extends StatelessWidget {
  InspectionFormScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InspectionController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('FORM INSPEKSI KENDARAAN (SURVEYOR)'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.yellow[200],
                width: double.infinity,
                child: const Text(
                  "PERINGATAN: Fitur Autosave aktif secara otomatis saat Anda mengetik atau mengubah data.",
                  style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              const Text("1. Nomor Polisi (Format Plat Indonesia)", style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: controller.nopolController,
                decoration: const InputDecoration(
                  hintText: "Contoh: B 1234 ABC",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Nomor polisi wajib diisi";
                  }
                  final regex = RegExp(r'^[A-Z]{1,2}\s\d{1,4}\s[A-Z]{1,3}$');
                  if (!regex.hasMatch(value.trim().toUpperCase())) {
                    return "Format plat nomor tidak valid (Gunakan format: B 1234 ABC)";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              const Text("2. Dokumentasi Foto (Kamera Wajib, Autowatermark)", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Obx(() => GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.8,
                children: controller.photos.keys.map((side) {
                  final data = controller.photos[side];
                  final isTaken = data != null;
                  return InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) => CameraSimulatorDialog(
                          sideName: side,
                          onCapture: () => controller.capturePhoto(side),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isTaken ? Colors.green[100] : Colors.grey[300],
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isTaken ? Icons.check_circle : Icons.camera_alt,
                            color: isTaken ? Colors.green : Colors.grey[700],
                            size: 30,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            side,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                            textAlign: TextAlign.center,
                          ),
                          if (isTaken)
                            const Text(
                              "Terfoto\n+Watermark",
                              style: TextStyle(color: Colors.green, fontSize: 8),
                              textAlign: TextAlign.center,
                            )
                          else
                            const Text(
                              "Wajib",
                              style: TextStyle(color: Colors.red, fontSize: 8),
                            )
                        ],
                      ),
                    ),
                  );
                }).toList(),
              )),
              const SizedBox(height: 15),
              const Text("3. Kondisi Kendaraan", style: TextStyle(fontWeight: FontWeight.bold)),
              Obx(() => DropdownButtonFormField<String>(
                initialValue: controller.eksterior.value,
                decoration: const InputDecoration(labelText: "Kondisi Eksterior", border: OutlineInputBorder()),
                items: ['Baik', 'Lecet Ringan', 'Rusak', 'Sangat Rusak'].map((String val) {
                  return DropdownMenuItem<String>(value: val, child: Text(val));
                }).toList(),
                onChanged: controller.setEksterior,
                validator: (val) => val == null ? "Wajib memilih kondisi eksterior" : null,
              )),
              const SizedBox(height: 10),
              Obx(() => DropdownButtonFormField<String>(
                initialValue: controller.mesin.value,
                decoration: const InputDecoration(labelText: "Kondisi Mesin", border: OutlineInputBorder()),
                items: ['Hidup Normal', 'Hidup Tidak Normal', 'Mati'].map((String val) {
                  return DropdownMenuItem<String>(value: val, child: Text(val));
                }).toList(),
                onChanged: controller.setMesin,
                validator: (val) => val == null ? "Wajib memilih kondisi mesin" : null,
              )),
              const SizedBox(height: 15),
              const Text("4. Kilometer Saat Ini (Odometer)", style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: controller.kmController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Masukkan angka saja",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Kilometer wajib diisi";
                  }
                  final numVal = int.tryParse(value);
                  if (numVal == null) {
                    return "Harus berupa angka bulat";
                  }
                  if (numVal <= 0) {
                    return "Kilometer tidak boleh 0 atau negatif";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              const Text("5. Lokasi Kendaraan Ditemukan", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Row(
                children: [
                  Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                    onPressed: controller.isGpsLoading.value ? null : controller.getGPSLocation,
                    child: controller.isGpsLoading.value
                        ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text("Ambil GPS Otomatis"),
                  )),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(() => Text(
                      controller.gpsLat.value != null && controller.gpsLng.value != null
                          ? "GPS: ${controller.gpsLat.value!.toStringAsFixed(6)}, ${controller.gpsLng.value!.toStringAsFixed(6)}"
                          : "GPS Belum Diambil",
                      style: TextStyle(
                        color: controller.gpsLat.value != null ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    )),
                  )
                ],
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: controller.alamatController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Keterangan Alamat / Lokasi Detail",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Keterangan alamat wajib diisi";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              const Text("6. Apakah Kendaraan Bisa Dipindahkan?", style: TextStyle(fontWeight: FontWeight.bold)),
              Obx(() => DropdownButtonFormField<String>(
                initialValue: controller.bisaDipindahkan.value,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: ['Ya', 'Tidak'].map((String val) {
                  return DropdownMenuItem<String>(value: val, child: Text(val));
                }).toList(),
                onChanged: controller.setBisaDipindahkan,
                validator: (val) => val == null ? "Pilih status bisa dipindahkan" : null,
              )),
              const SizedBox(height: 10),
              Obx(() {
                if (controller.bisaDipindahkan.value == 'Tidak') {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Alasan Tidak Bisa Dipindahkan (Wajib, Minimal 30 Karakter)",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: controller.alasanController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: "Tuliskan alasan kenapa tidak bisa dipindahkan...",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (controller.bisaDipindahkan.value == 'Tidak') {
                            if (value == null || value.trim().isEmpty) {
                              return "Alasan wajib diisi";
                            }
                            if (value.trim().length < 30) {
                              return "Alasan terlalu pendek (${value.trim().length}/30 karakter)";
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),
              const Text("7. Catatan Tambahan (Opsional)", style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: controller.catatanController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: "Masukkan catatan tambahan bila perlu...",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              Obx(() => FaceVerificationBox(
                isVerified: controller.isDebtorVerified.value,
                verificationMessage: controller.debtorVerificationMessage.value,
                onFailTrigger: controller.failFaceMatch,
                onBypassTrigger: controller.bypassFaceMatch,
              )),
              const SizedBox(height: 15),
              const Text("9. Tanda Tangan Digital (Wajib)", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Obx(() => SignatureCanvas(
                points: controller.signaturePoints.toList(),
                onPointAdded: controller.addSignaturePoint,
                onClear: controller.clearSignature,
              )),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[800],
                  ),
                  onPressed: () => controller.submitInspection(context, _formKey),
                  child: const Text("KIRIM DATA INSPEKSI", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
