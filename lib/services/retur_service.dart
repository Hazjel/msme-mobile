import '../models/retur_pembelian.dart';
import 'api_client.dart';

class ReturService {
  final _dio = ApiClient().dio;

  Future<List<ReturPembelian>> list({String? search, int? supplierId}) async {
    final res = await _dio.get('/retur-pembelian', queryParameters: {
      'q': ?search,
      'supplier_id': ?supplierId,
    });
    final list = res.data['data'] as List;
    return list.map((e) => ReturPembelian.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ReturPembelian> show(int id) async {
    final res = await _dio.get('/retur-pembelian/$id');
    return ReturPembelian.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> sisaRetur(int pembelianId) async {
    final res = await _dio.get('/pembelian/$pembelianId/sisa-retur');
    return res.data as Map<String, dynamic>;
  }

  Future<ReturPembelian> store(Map<String, dynamic> payload) async {
    final res = await _dio.post('/retur-pembelian', data: payload);
    return ReturPembelian.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> destroy(int id) async {
    await _dio.delete('/retur-pembelian/$id');
  }
}
