class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';

  static const String categories = '/categories';
  static const String services = '/services';
  static const String bookings = '/bookings';

  static const String providerBookings = '/provider/bookings';
  static const String providerServices = '/provider/services';
  static const String providerProfile = '/provider/profile';
}
