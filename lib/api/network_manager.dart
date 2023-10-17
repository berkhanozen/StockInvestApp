import 'package:dio/dio.dart';

class ProjectNetworkManager
{
  ProjectNetworkManager._()
  {
    _dio = Dio(BaseOptions(baseUrl: "https://api.collectapi.com"));
  }

  late final Dio _dio;

  static ProjectNetworkManager instance = ProjectNetworkManager._();

  Dio get service => _dio;

  void addBaseHeaderToToken(String token)
  {
    _dio.options = _dio.options.copyWith(
      headers: {
        "authorization": token,
        "content-type" : "application/json"
      }
    );
  }
}