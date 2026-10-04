import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String address;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

class LocationService {
  static final Geocoding _geocoding = Geocoding();

  /// Mendapatkan lokasi saat ini beserta alamat hasil reverse geocoding
  static Future<LocationResult> getCurrentLocationWithAddress() async {
    // 1. Cek apakah layanan GPS aktif
    final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      throw Exception(
        'Layanan lokasi (GPS) sedang nonaktif. Mohon aktifkan GPS di pengaturan perangkat Anda.',
      );
    }

    // 2. Cek izin lokasi
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception(
          'Izin akses lokasi ditolak. Aplikasi memerlukan izin lokasi untuk verifikasi kehadiran.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Izin akses lokasi ditolak secara permanen. Silakan izinkan akses lokasi melalui menu Pengaturan Aplikasi.',
      );
    }

    // 3. Ambil posisi koordinat
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );

    // 4. Lakukan reverse geocoding untuk mendapatkan alamat
    String resolvedAddress =
        'Koordinat: ${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';

    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = <String>[
          if (place.street != null && place.street!.trim().isNotEmpty)
            place.street!.trim(),
          if (place.subLocality != null && place.subLocality!.trim().isNotEmpty)
            place.subLocality!.trim(),
          if (place.locality != null && place.locality!.trim().isNotEmpty)
            place.locality!.trim(),
          if (place.administrativeArea != null &&
              place.administrativeArea!.trim().isNotEmpty)
            place.administrativeArea!.trim(),
        ];

        if (parts.isNotEmpty) {
          resolvedAddress = parts.join(', ');
        }
      }
    } catch (_) {
      // Jika geocoding gagal/timeout, gunakan format koordinat yang sudah ada
    }

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      address: resolvedAddress,
    );
  }
}
