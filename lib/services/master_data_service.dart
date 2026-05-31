import '../models/barang.dart';
import '../models/supplier.dart';
import 'api_client.dart';

class MasterDataService {
  final _dio = ApiClient().dio;

  Future<List<Supplier>> suppliers() async {
    final res = await _dio.get('/suppliers');
    return (res.data['data'] as List)
        .map((e) => Supplier.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Barang>> barangs() async {
    final res = await _dio.get('/barangs');
    return (res.data['data'] as List)
        .map((e) => Barang.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
