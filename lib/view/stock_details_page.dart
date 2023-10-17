import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_route.dart';
import 'package:flutter/material.dart';
import 'package:fonyat/constants.dart';
import 'package:fonyat/model/currency_model.dart';
import 'package:fonyat/model/stock_model.dart';
import 'package:fonyat/theme.dart';
import 'package:fonyat/utility/daily_stock_opeations.dart';
import 'package:fonyat/view/home_page.dart';
import 'package:sizer/sizer.dart';

class StockDetailsPage extends StatefulWidget {

  StockDetailsPage({Key? key, required this.stock,required this.currency,required this.currentEUR,required this.currentUSD}) : super(key: key);

  final Result stock;
  final DetailsPageCurrency currency;
  final double currentEUR;
  final double currentUSD;

  @override
  State<StockDetailsPage>createState() => _StockDetailsPageState();
}

class _StockDetailsPageState extends State<StockDetailsPage> {
  @override
  Widget build(BuildContext context) {
    Result stock = widget.stock;
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(onPressed: () async {
        DateTime? pickedDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1990), lastDate: DateTime.now());
      }, backgroundColor: Colors.white, child: const Icon(Icons.add)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CardItem(item1: stock.code, item2: stock.text,
                item1FontSize: 22.sp, item2FontSize: 18.sp),

            StockPriceItem(item1: "Hisse Fiyatı: ", item2: (stock.lastprice!).toStringAsFixed(2),currency: widget.currency),

            Row(
              children: [
                Expanded(flex: 1, child: CardItem(item1: "Hacim", item2: stock.hacim)),
                Expanded(flex: 1, child: CardItem(item1: "Değişim (%)", item2: stock.rate?.toStringAsFixed(2))),
              ],
            ),

            DailyStockView(stockName: stock.code, currencySymbol: widget.currency.symbol ?? "", currentEUR: widget.currentEUR, currentUSD: widget.currentUSD ),
              ],
            ),
      ),
    );
  }
}

class CardItem extends StatelessWidget
{
  final String? item1;
  final String? item2;
  final double? item1FontSize;
  final double? item2FontSize;

  final double defaultItem1FontSize = 14.sp;
  final double defaultItem2FontSize = 12.sp;

  CardItem({super.key, this.item1, this.item2, this.item1FontSize, this.item2FontSize});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.sp),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(item1 ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: item1FontSize ?? defaultItem1FontSize,
                    fontWeight: FontWeight.bold)),
                SizedBox(height: 4.sp),
                Text(item2 ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: item2FontSize ?? defaultItem2FontSize)
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StockPriceItem extends StatelessWidget
{
  final String? item1;
  final String? item2;
  String? currencySymbol;
  final DetailsPageCurrency currency;

  final double stockPriceFontSize = 18.sp;

  StockPriceItem({super.key, this.item1, this.item2, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.sp),
        child: Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item1 ?? '',
                  style: TextStyle(fontSize: stockPriceFontSize, fontWeight: FontWeight.bold)),
              Text("${item2.toString()} ${currency.symbol}",
                  style: TextStyle(fontSize: stockPriceFontSize))
            ]),
      ),
    );
  }
}