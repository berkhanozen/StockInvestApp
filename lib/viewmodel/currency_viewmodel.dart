import 'package:flutter/material.dart';
import 'package:fonyat/api/currency_service.dart';
import 'package:fonyat/api/network_manager.dart';
import 'package:fonyat/model/currency_model.dart';
import 'package:fonyat/view/home_page.dart';

class CurrencyViewModel
{
  late final ICurrencyService currencyService = CurrencyService(ProjectNetworkManager.instance.service);


  Future<List<ResultC>> fetch() async
  {
    List<ResultC> currency = [];
    ProjectNetworkManager.instance.addBaseHeaderToToken('apikey');
    currency = (await currencyService.fetchCurrencyItem())?.result ?? [];
    return currency;
  }
}