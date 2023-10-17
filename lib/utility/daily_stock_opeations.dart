import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fonyat/constants.dart';
import 'package:fonyat/view/home_page.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

class DailyStockView extends StatefulWidget {
  final String? stockName;
  final String currencySymbol;
  final double currentEUR;
  final double currentUSD;
  const DailyStockView({super.key, this.stockName,required this.currencySymbol,required this.currentEUR,required this.currentUSD});

  @override
  State<DailyStockView> createState() => DailyStockViewState();
}

class DailyStockViewState extends State<DailyStockView> {

  Future<YahooFinanceResponse>? dailyStockResponse;
  int frequenceDay = 30;
  int day5 = 5;
  int day15 = 15;
  int month1 = 30;
  int month3 = 90;
  int month6 = 180;
  int year1 = 360;
  int year5 = 1800;
  late int allTime;

  Future<void> fetchData(int frequenceDay) async {
    setState(() {
      this.frequenceDay = frequenceDay;
      dailyStockResponse = const YahooFinanceDailyReader().getDailyDTOs('${widget.stockName}.IS');
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData(frequenceDay);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: dailyStockResponse,
      builder: (BuildContext context,
          AsyncSnapshot<YahooFinanceResponse> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          YahooFinanceResponse response = snapshot.data!;
          allTime = response.candlesData.length-1;
          return Column(
            children: [
              TimeButtonsRow(
                item1: OutlinedButton(
                    onPressed: () { fetchData(day5); },
                    child: const Text("5D", style: TextStyle(fontWeight: FontWeight.bold))
                  ),
                item2: OutlinedButton(
                    onPressed: () { fetchData(day15); },
                    child: const Text("15D", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                item3: OutlinedButton(
                    onPressed: () { fetchData(month1); },
                    child: const Text("1M", style: TextStyle(fontWeight: FontWeight.bold))
                ),
                item4: OutlinedButton(
                    onPressed: () { fetchData(month3); },
                    child: const Text("3M", style: TextStyle(fontWeight: FontWeight.bold))
                ),
              ),
              SizedBox(height: 1.h,),
              TimeButtonsRow(
                item1: OutlinedButton(
                    onPressed: () { fetchData(month6); },
                    child: const Text("6M", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                item2: OutlinedButton(
                  onPressed: () { fetchData(year1); },
                  child: const Text("1Y", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                item3: OutlinedButton(
                    onPressed: () { fetchData(year5); },
                    child: const Text("5Y", style: TextStyle(fontWeight: FontWeight.bold))
                ),
                item4: OutlinedButton(
                    onPressed: () { fetchData(allTime); },
                    child: const Text("MAX", style: TextStyle(fontWeight: FontWeight.bold))
                ),
              ),

              DailyStockOperations(response: response, freqDay: frequenceDay,currencySymbol: widget.currencySymbol,currentEUR: widget.currentEUR,currentUSD:widget.currentUSD),
            ],
          );
        }
        else {
          return const Center(
            child: SizedBox(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

class DailyStockOperations extends StatefulWidget
{
  final YahooFinanceResponse? response;
  final int freqDay;
  final String currencySymbol;
  final double currentEUR;
  final double currentUSD;
  const DailyStockOperations({super.key, required this.response, required this.freqDay,required this.currencySymbol,required this.currentUSD,required this.currentEUR});

  @override
  State<DailyStockOperations> createState() => _DailyStockOperationsState();
}

class _DailyStockOperationsState extends State<DailyStockOperations> {
  TrackballBehavior? trackballBehavior;

  @override
  void initState(){
    trackballBehavior = TrackballBehavior(
        enable: true,
        lineColor: kButtonColor,
        activationMode: ActivationMode.singleTap,
        tooltipSettings: const InteractiveTooltip(
          enable: true,
          format: 'point.x : point.y',
        )
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<PriceData> chartData = [];
    List<PriceData> maData = [];
    int todayIndex =  widget.response!.candlesData.length-1;

    String mA(int maDay)
    {
      double maValue = 0;
      for(int i = 0; i < maDay; i++)
      {
        switch(widget.currencySymbol){
          case "₺" :
            maValue += widget.response!.candlesData[todayIndex-i].close;
            break;
          case "\$":
            maValue += widget.response!.candlesData[todayIndex-i].close / widget.currentUSD;
            break;
          case "€" :
            maValue += widget.response!.candlesData[todayIndex-i].close / widget.currentEUR;
            break;
        }
      }
      return (maValue/maDay).toStringAsFixed(2);
    }

    for(int i = 0; i < widget.freqDay; i++)
    {
      switch(widget.currencySymbol){
        case "₺" :
          chartData.add(PriceData(widget.response?.candlesData[todayIndex-i].date,
              (widget.response?.candlesData[todayIndex-i].close)!));
          break;
        case "\$":
          chartData.add(PriceData(widget.response?.candlesData[todayIndex-i].date,
              (widget.response?.candlesData[todayIndex-i].close)! / widget.currentUSD));
          break;
        case "€" :
          chartData.add(PriceData(widget.response?.candlesData[todayIndex-i].date,
              (widget.response?.candlesData[todayIndex-i].close)! / widget.currentEUR));
          break;
      }
      if(widget.freqDay < 101)
        {
          maData.add(PriceData(widget.response?.candlesData[todayIndex-i].date, double.parse(mA(i+1))));
        }
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          SfCartesianChart(
            primaryXAxis: DateTimeAxis(),
            trackballBehavior: trackballBehavior,
            legend: Legend(isVisible:  true, position: LegendPosition.bottom),
            series: <ChartSeries>[
              // Renders line chart
              LineSeries<PriceData, DateTime>(
                name: "Hisse Grafiği",
                dataSource: chartData,
                xValueMapper: (PriceData sales, _) => sales.date,
                yValueMapper: (PriceData sales, _) => sales.price,
              ),
              LineSeries<PriceData, DateTime>(
                name: "Hareketli Ortalama",
                dataSource: maData,
                xValueMapper: (PriceData sales, _) => sales.date,
                yValueMapper: (PriceData sales, _) => sales.price,
              ),
            ],
          ),
          MaItem(item1: "5 Günlük Hareketli Ortalama: ", item2: mA(5)),
          MaItem(item1: "10 Günlük Hareketli Ortalama: ", item2: mA(10)),
          MaItem(item1: "20 Günlük Hareketli Ortalama: ", item2: mA(20)),
          MaItem(item1: "50 Günlük Hareketli Ortalama: ", item2: mA(50)),
          MaItem(item1: "100 Günlük Hareketli Ortalama: ", item2: mA(100)),
        ],
      ),
    );
  }
}

class MaItem extends StatelessWidget
{
  final String? item1;
  final String? item2;

  MaItem({super.key, this.item1, this.item2});

  final double defaultItem1FontSize = 14.sp;
  final double defaultItem2FontSize = 12.sp;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.sp),
        child: Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item1 ?? '',
                  style: TextStyle(fontSize: defaultItem1FontSize, fontWeight: FontWeight.bold)),
              Text(item2.toString(),
                  style: TextStyle(fontSize: defaultItem2FontSize))
            ]),
      ),
    );
  }
}

class TimeButtonsRow extends StatelessWidget
{
  Widget? item1;
  Widget? item2;
  Widget? item3;
  Widget? item4;
  double width = 40.sp;
  double height = 40.sp ;

  TimeButtonsRow({super.key, this.item1, this.item2, this.item3, this.item4});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(width: width, height: height, child: item1),
        SizedBox(width: width, height: height, child: item2),
        SizedBox(width: width, height: height, child: item3),
        SizedBox(width: width, height: height, child: item4),
      ],
    );
  }
}

class PriceData {
  DateTime? date;
  double? price;

  PriceData(this.date, this.price);
}

