import '../models/stok_input.dart';
import 'api_client.dart';

class StokInputService {
  final _dio = ApiClient().dio;

  Future<List<StokInput>> list({int? barangId, String? start, String? end, String? search}) async {
    final res = await _dio.get('/stok-input', queryParameters: {
      'barang_id': ?barangId,
      'start': ?start,
      'end': ?end,
      'q': ?search,
    });
    final list = res.data['data'] as List;
    return list.map((e) => StokInput.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<StokInput> show(int id) async {
    final res = await _dio.get('/stok-input/$id');
    return StokInput.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<StokInput> store({
    required int barangId,
    required int qtyInput,
    String? keterangan,
    String? tanggal,
  }) async {
    final res = await _dio.post('/stok-input', data: {
      'barang_id': barangId,
      'qty_input': qtyInput,
      'keterangan': ?keterangan,
      'tanggal': ?tanggal,
    });
    return StokInput.fromJson(res.data['data'] as Map<String, dynamic>);
  }
}
