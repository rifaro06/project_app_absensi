import 'package:intl/intl.dart';

class DateHelper {
  /// Format tanggal standar Indonesia: "Senin, 3 Oktober 2026"
  static String formatIndonesianDate(dynamic dateInput) {
    if (dateInput == null) return '-';
    DateTime? dt;
    if (dateInput is DateTime) {
      dt = dateInput;
    } else if (dateInput is String) {
      dt = DateTime.tryParse(dateInput);
    }

    if (dt == null) return dateInput.toString();
    try {
      return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(dt.toLocal());
    } catch (_) {
      return DateFormat('EEEE, d MMMM yyyy').format(dt.toLocal());
    }
  }

  /// Format waktu dengan akhiran WIB: "08:15 WIB"
  static String formatTime(dynamic timeInput) {
    if (timeInput == null) return '--:--';
    DateTime? dt;
    if (timeInput is DateTime) {
      dt = timeInput;
    } else if (timeInput is String) {
      dt = DateTime.tryParse(timeInput);
    }

    if (dt != null) {
      final local = dt.toLocal();
      final hour = local.hour.toString().padLeft(2, '0');
      final minute = local.minute.toString().padLeft(2, '0');
      return '$hour:$minute WIB';
    }

    // Jika string sudah berformat "HH:mm" atau "HH:mm:ss"
    final str = timeInput.toString();
    if (str.length >= 5) {
      if (str.contains(':')) {
        final parts = str.split(' ');
        final timePart = parts.isNotEmpty ? parts.last : str;
        if (timePart.length >= 5) {
          return '${timePart.substring(0, 5)} WIB';
        }
      }
    }

    return '$str WIB';
  }

  /// Format lengkap tanggal dan jam: "Sabtu, 3 Oktober 2026, 08:15 WIB"
  static String formatFullDateTime(dynamic input) {
    if (input == null) return '-';
    return '${formatIndonesianDate(input)}, ${formatTime(input)}';
  }
}
