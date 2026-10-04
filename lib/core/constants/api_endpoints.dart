class ApiEndpoints {
  static const String login = '/login';
  static const String register = '/register';
  static const String checkIn = '/absen/check-in';
  static const String checkOut = '/absen/check-out';
  static const String history = '/absen/history';
  static const String profile = '/profile';
  static const String users = '/users';

  static String deleteAbsen(int id) => '/absen/$id';
}
