class ApiConstants {
  ApiConstants._();

  // chạy trên trình duyệt chrome or edge
  //static const String baseUrl = 'http://127.0.0.1:8000/api';

  // chạy trên điện thoại android
  // static const String baseUrl = 'http://192.168.22.28:8000/api'; //192.168.22.28 là IPv4 của mạng, nếu connect mạng khác cần tim 'ipconfig' để set lại

  // chạy trên emulator Android Studio
  //static const String baseUrl = 'http://10.0.2.2:8000/api';

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api',
  );

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';

  static const String categories = '/categories';
  static const String services = '/services';
  static const String bookings = '/bookings';
  static const String reviews = '/reviews';

  static const String providerApplication = '/provider-application';
  static const String providerBookings = '/provider/bookings';
  static const String providerServices = '/provider/services';
  static const String providerProfile = '/provider/profile';

  static const String notifications = '/notifications';
}
