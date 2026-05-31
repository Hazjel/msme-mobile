import '../models/dashboard.dart';
import 'api_client.dart';

class LaporanService {
  final _dio = ApiClient().dio;

  Future<DashboardSummary> dashboard() async {
    final res = await _dio.get('/dashboard');
    return DashboardSummary.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> laporanPembelian({String? start, String? end, int? supplierId}) async {
    final res = await _dio.get('/laporan/pembelian', queryParameters: {
      if (start != null) 'start': start,
      if (end != null) 'end': end,
      if (supplierId != null) 'supplier_id': supplierId,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> laporanRetur({String? start, String? end, int? supplierId}) async {
    final res = await _dio.get('/laporan/retur-pembelian', queryParameters: {
      if (start != null) 'start': start,
      if (end != null) 'end': end,
      if (supplierId != null) 'supplier_id': supplierId,
    });
    return res.data as Map<String, dynamic>;
  }
}
