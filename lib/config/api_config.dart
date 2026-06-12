class ApiConfig {
  // GANTI sesuai IP server Laravel saat dev
  // Android emulator: http://10.0.2.2:8000
  // HP fisik (WiFi sama): http://<IP_PC>:8000
  static const String baseUrl = 'http://192.168.1.11:8000/api/v1';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
