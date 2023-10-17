import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fonyat/api/network_manager.dart';
import 'package:fonyat/api/stock_service.dart';
import 'package:fonyat/model/stock_model.dart';
import 'package:fonyat/view/home_page.dart';

 class StockViewModel
{
  final IStockService stockService = StockService(ProjectNetworkManager.instance.service);
  late StreamController<List<Result>> stockStreamController = StreamController<List<Result>>.broadcast();


  List<Result> stocks = [];

  Future<List<Result>> fetch() async
  {
    ProjectNetworkManager.instance.addBaseHeaderToToken('apikey');
    stocks = (await stockService.fetchStockItem())?.result ?? [];
    stockStreamController.sink.add(stocks);
    return stocks;
  }
}