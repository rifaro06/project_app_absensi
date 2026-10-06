import 'package:intl/intl.dart';

class DateHelper {
  /// Mem-parsing input (DateTime atau String) dari API menjadi DateTime lokal (WIB).
  /// Menangani format ISO8601 dengan atau tanpa 'Z', format SQL/Laravel "YYYY-MM-DD HH:mm:ss",
  /// serta format jam saja "HH:mm:ss" atau "HH:mm".
  static DateTime? parseDateTime(dynamic input) {
    if (input == null) return null;
    if (input is DateTime) {
      return input.isUtc ? input.toLocal() : input;
    }

    final str = input.toString().trim();
    if (str.isEmpty || str == '-' || str == '--:--' || str.toLowerCase() == 'null') {
      return null;
    }

    // 1. Jika sudah memiliki penanda timezone (Z atau offset seperti +07:00 / +00:00)
    if (str.endsWith('Z') || RegExp(r'[+-]\d{2}(:?\d{2})?$').hasMatch(str)) {
      return DateTime.tryParse(str)?.toLocal();
    }

    // 2. Format standar MySQL / Laravel: "YYYY-MM-DD HH:mm:ss" atau "YYYY-MM-DDTHH:mm:ss"
    // Server backend berjalan di UTC (GMT), sehingga harus dikonversi ke waktu lokal pengguna.
    final iso = str.replaceFirst(' ', 'T');
    if (RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}').hasMatch(iso)) {
      final dtUtc = DateTime.tryParse('${iso}Z');
      if (dtUtc != null) {
        return dtUtc.toLocal();
      }
    }

    // 3. Format jam saja: "HH:mm:ss" atau "HH:mm" yang tercatat dalam UTC
    if (RegExp(r'^\d{1,2}:\d{2}(:\d{2})?$').hasMatch(str)) {
      final parts = str.split(':');
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      final s = parts.length > 2 ? (int.tryParse(parts[2]) ?? 0) : 0;

      final nowUtc = DateTime.now().toUtc();
      final dtUtc = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day, h, m, s);
      return dtUtc.toLocal();
    }

    // 4. Fallback parsing biasa
    return DateTime.tryParse(str)?.toLocal();
  }

  /// Format tanggal standar Indonesia: "Senin, 3 Oktober 2026"
  static String formatIndonesianDate(dynamic dateInput) {
    if (dateInput == null) return '-';
    final dt = parseDateTime(dateInput);
    if (dt == null) return dateInput.toString();

    try {
      return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      return DateFormat('EEEE, d MMMM yyyy').format(dt);
    }
  }

  /// Format waktu dengan akhiran WIB: "08:15 WIB"
  static String formatTime(dynamic timeInput) {
    if (timeInput == null) return '--:--';
    final dt = parseDateTime(timeInput);
    if (dt != null) {
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$hour:$minute WIB';
    }

    final str = timeInput.toString().trim();
    if (str.isEmpty || str == '-' || str.toLowerCase() == 'null') return '--:--';
    return '$str WIB';
  }

  /// Format lengkap tanggal dan jam: "Sabtu, 3 Oktober 2026, 08:15 WIB"
  static String formatFullDateTime(dynamic input) {
    if (input == null) return '-';
    return '${formatIndonesianDate(input)}, ${formatTime(input)}';
  }
}
