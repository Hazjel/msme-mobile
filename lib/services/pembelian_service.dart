import '../models/pembelian.dart';
import 'api_client.dart';

class PembelianService {
  final _dio = ApiClient().dio;

  Future<List<Pembelian>> list({String? search, int? supplierId, String? start, String? end}) async {
    final res = await _dio.get('/pembelian', queryParameters: {
      'q': ?search,
      'supplier_id': ?supplierId,
      'start': ?start,
      'end': ?end,
    });
    final list = res.data['data'] as List;
    return list.map((e) => Pembelian.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Pembelian> show(int id) async {
    final res = await _dio.get('/pembelian/$id');
    return Pembelian.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<Pembelian> store(Map<String, dynamic> payload) async {
    final res = await _dio.post('/pembelian', data: payload);
    return Pembelian.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<Pembelian> update(int id, Map<String, dynamic> payload) async {
    final res = await _dio.put('/pembelian/$id', data: payload);
    return Pembelian.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> destroy(int id) async {
    await _dio.delete('/pembelian/$id');
  }
}
