import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fonyat/model/stock_model.dart';

abstract class IStockService
{
  IStockService(this.dio);
  final Dio dio;

  Future<StockModel?> fetchStockItem();
}


class StockService extends IStockService
{
  StockService(Dio dio) : super(dio);

  @override
  Future<StockModel?> fetchStockItem() async {
    final response = await dio.get("/economy/hisseSenedi");

    if(response.statusCode == HttpStatus.ok)
    {
      final jsonBody = response.data;
      if(jsonBody is Map<String, dynamic>)
      {
        return StockModel.fromJson(jsonBody);
      }
    }
    return null;
  }
}