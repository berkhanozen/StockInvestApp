import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fonyat/model/currency_model.dart';

abstract class ICurrencyService
{
  ICurrencyService(this.dio);
  final Dio dio;

  Future<CurrencyModel?> fetchCurrencyItem();
}


class CurrencyService extends ICurrencyService
{
  CurrencyService(Dio dio) : super(dio);

  @override
  Future<CurrencyModel?> fetchCurrencyItem() async {
    final response = await dio.get("/economy/allCurrency");

    if(response.statusCode == HttpStatus.ok)
    {
      final jsonBody = response.data;
      if(jsonBody is Map<String, dynamic>)
      {
        return CurrencyModel.fromJson(jsonBody);
      }
    }
    return null;
  }
}