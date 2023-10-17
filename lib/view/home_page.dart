import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fonyat/model/currency_model.dart';
import 'package:fonyat/model/stock_model.dart';
import 'package:fonyat/view/portfolio.dart';
import 'package:fonyat/view/stock_details_page.dart';
import 'package:fonyat/viewmodel/stock_viewmodel.dart';
import 'package:fonyat/viewmodel/currency_viewmodel.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {

    List<Widget> pageList = [
      const MainPage(),
      const Portfolio(),
    ];

    return Scaffold(
      body: pageList[pageIndex],
          bottomNavigationBar: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.abc), label: "Hisse Listesi"),
                BottomNavigationBarItem(icon: Icon(Icons.abc), label: "Portföy")
              ],
          currentIndex: pageIndex,
          onTap: (value) => setState(() {pageIndex = value;})
          )
    );
  }
}

class MainPage extends StatefulWidget
{
  const MainPage({super.key});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {

  StreamController<CurrencyChange> dropdownStreamController = StreamController<CurrencyChange>.broadcast();
  final StockViewModel _stockViewModel = StockViewModel();
  final TextEditingController _controller = TextEditingController();
  List<Result> list = [];
  List<Result> temp = [];

  @override
  void initState() {
    _stockViewModel.fetch().then((value) => list = value);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 1.w),
              SizedBox(
                  width: 60.w,
                  child: TextField(
                    controller: _controller,
                    onChanged: (value) {
                        if(value == ""){
                          _stockViewModel.stockStreamController.sink.add(list);
                          return;
                        }
                        temp = [];
                        for(int i=0;i<list.length;i++){
                          if(list[i].text!.toLowerCase().startsWith(value.toLowerCase()) || list[i].text!.toLowerCase().contains(value.toLowerCase())){
                              temp.add(list[i]);
                          }
                        }
                        if(temp.isEmpty){
                          list = [];
                          _stockViewModel.stockStreamController.sink.add(list);
                          return;
                        }
                        _stockViewModel.stockStreamController.sink.add(temp);
                    },
                    decoration:const InputDecoration(
                      icon: Icon(Icons.search)
                    ),

                  )),
              CurrencyButton(currencyStreamController: dropdownStreamController),
              SizedBox(width: 1.w,)
            ],
          ),
          const StockTableHeader(),
          StockTableList(currencyStreamController: dropdownStreamController,stockViewModel: _stockViewModel,)
        ],
      ),
    );
  }
}

class CurrencyButton extends StatefulWidget
{
  String currencyName  = 'TRY';

  StreamController<CurrencyChange> currencyStreamController;

  CurrencyButton({super.key, required this.currencyStreamController});

  @override
  CurrencyButtonState createState() => CurrencyButtonState();
}

class CurrencyButtonState extends State<CurrencyButton> {

  List<ResultC> currency = [];

  late final curItems = [
    'TRY',
    'USD',
    'EUR',
  ];

  final CurrencyViewModel viewModel = CurrencyViewModel();

  @override
  void initState() {
    viewModel.fetch().then((value) {
      currency = value;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: widget.currencyName,
      icon: const Icon(Icons.keyboard_arrow_down),
      items: curItems.map((String curItems) {
        return DropdownMenuItem(
          value: curItems,
          child: Text(curItems),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if(widget.currencyName == newValue)
        {
          return;
        }
        String symbol = "";
        switch(newValue)
        {
          case "TRY": symbol = "₺";
          break;
          case "USD": symbol = "\$";
          break;
          case "EUR": symbol = "€";
          break;
        }
        widget.currencyStreamController.sink.add(CurrencyChange(isChanged: true, newCurrency: newValue, oldCurrency: widget.currencyName, symbol: symbol));
        setState(() {
          widget.currencyName = newValue!;
        });
        //changeCurrency();
      },
    );
  }
}

class StockTableHeader extends StatelessWidget
{
  const StockTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      color: Colors.black45,
      child: Row(
        children: [
          Expanded(flex:2,
              child: Container(
                  child: const Text("Hisse Kodu",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold)))),
          const Expanded(
              flex:3,
              child: Text("Hisse Adı",
                textAlign: TextAlign.center)
          ),
          Expanded(flex:2,
            child: Container(
              child: const Column(
                children: [
                  Text("Hisse Fiyatı", textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Değişim (%)"),
                  ],
                ),
            ),
          )
        ],
      ),
    );
  }
}

class StockTableList extends StatefulWidget
{
  StockViewModel stockViewModel;
  StreamController<CurrencyChange> currencyStreamController;

  StockTableList({Key? key, required this.currencyStreamController,required this.stockViewModel}) : super(key: key);

  @override
  StockTableListState createState() => StockTableListState();
}

class StockTableListState extends State<StockTableList>  {
  List<Result> firstValues = [];
  final CurrencyViewModel _currencyViewModel = CurrencyViewModel();
  StreamController<String> symbolStreamController = StreamController<String>.broadcast();
  double currentTRY = 0;
  double currentEUR = 0;
  double currentUSD = 0;

  @override
  void initState() {
    _currencyViewModel.fetch().then((value) {
      currentUSD = value.elementAt(0).buying ?? 0;
      currentEUR = value.elementAt(1).buying ?? 0;
    });

    double hacimStringToDouble(String hacim)
    {
      return double.parse(hacim.substring(1).split(",")[0].replaceAll(".", ""));
    }

    String hacimDoubleToString(double hacim, String symbol)
    {
      String hacimStr = hacim.toStringAsFixed(0);
      final f = NumberFormat.currency(locale: "tr_TR", symbol: symbol);
      return f.format(double.parse(hacimStr));
    }

    widget.currencyStreamController.stream.listen((event) {
        if (event.isChanged!) {
          switch (event.oldCurrency) {
            case 'TRY':
              for (int i = 0; i < firstValues.length; i++) {
                firstValues[i].lastprice = event.newCurrency == 'EUR'
                    ? firstValues[i].lastprice! / currentEUR
                    : firstValues[i].lastprice! / currentUSD;

                firstValues[i].rate = event.newCurrency == 'EUR'
                    ? firstValues[i].rate! / currentEUR
                    : firstValues[i].rate! / currentUSD;

                firstValues[i].hacim = (event.newCurrency == 'EUR'
                    ? hacimDoubleToString(hacimStringToDouble(firstValues[i].hacim!) / currentEUR, event.symbol!)
                    : hacimDoubleToString(hacimStringToDouble(firstValues[i].hacim!) / currentUSD, event.symbol!));
              }
              break;
            case 'EUR':
              for (int i = 0; i < firstValues.length; i++) {
                firstValues[i].lastprice = event.newCurrency == 'TRY'
                    ? firstValues[i].lastprice! * currentEUR
                    : firstValues[i].lastprice! / (currentUSD / currentEUR);

                firstValues[i].rate = event.newCurrency == 'TRY'
                    ? firstValues[i].rate! * currentEUR
                    : firstValues[i].rate! / (currentUSD / currentEUR);

                firstValues[i].hacim = (event.newCurrency == 'TRY'
                    ? hacimDoubleToString(hacimStringToDouble(firstValues[i].hacim!) * currentEUR, event.symbol!)
                    : hacimDoubleToString(hacimStringToDouble(firstValues[i].hacim!) / (currentUSD / currentEUR), event.symbol!));
              }
              break;
            case 'USD':
              for (int i = 0; i < firstValues.length; i++) {
                firstValues[i].lastprice = event.newCurrency == 'TRY'
                    ? firstValues[i].lastprice! * currentUSD
                    : firstValues[i].lastprice! / (currentEUR / currentUSD);

                firstValues[i].rate = event.newCurrency == 'TRY'
                    ? firstValues[i].rate! * currentUSD
                    : firstValues[i].rate! / (currentEUR / currentUSD);

                firstValues[i].hacim = (event.newCurrency == 'TRY'
                    ? hacimDoubleToString(hacimStringToDouble(firstValues[i].hacim!) * currentUSD, event.symbol!)
                    : hacimDoubleToString(hacimStringToDouble(firstValues[i].hacim!) / (currentEUR / currentUSD), event.symbol!));
              }
              break;
          }
          widget.stockViewModel.stockStreamController.sink.add(firstValues);
          symbolStreamController.sink.add(event.symbol ?? "");
        }
    });
    widget.stockViewModel.stockStreamController.stream.listen((event) {firstValues = event;});

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<List<Result>>(
        stream: widget.stockViewModel.stockStreamController.stream,
        builder: (context, snapshot) {
          if(snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return StreamBuilder<String>(
            stream: symbolStreamController.stream,
            initialData: "₺",
            builder: (context, symbol) {
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index){
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: StockCard(
                      col1: StockCodeCol(colText: snapshot.data?[index].code ?? ''),
                      col2: StockNameCol(colText: snapshot.data?[index].text ?? ''),
                      col3: StockValueCol(
                        price: (snapshot.data?[index].lastprice!)?.toStringAsFixed(2),
                        rate: (snapshot.data?[index].rate)?.toStringAsFixed(2),
                        symbol: symbol.data,
                      ),
                      cardHeight: 75),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StockDetailsPage(stock: snapshot.data![index],currency: DetailsPageCurrency(symbol.data, snapshot.data?[index].lastprice), currentEUR: currentEUR, currentUSD: currentUSD),
                      ),
                    );
                  },
                );
              });
            }
          );
        }
      ),
    );
  }
}

class StockCard extends StatelessWidget
{
  final Widget col1;
  final Widget col2;
  final Widget col3;
  final double cardHeight;

  const StockCard({super.key, required this.col1, required this.col2, required this.col3, required this.cardHeight});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardHeight,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: <Widget>[
            Expanded(flex:2, child: col1),
            Expanded(flex:3, child: col2),
            Expanded(flex:2, child: col3),
          ],
        ),
      ),
    );
  }
}

class StockCodeCol extends StatelessWidget
{
  final String? colText;

  const StockCodeCol({super.key, this.colText});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.sp),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(colText ?? '',
              style: TextStyle(fontSize: 16.sp,
              fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class StockNameCol extends StatelessWidget
{
  final String? colText;
  const StockNameCol({super.key, this.colText});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.sp),
      child: Text(colText ?? '', textAlign: TextAlign.center),
    );
  }
}

class StockValueCol extends StatelessWidget
{
  final String? price;
  final String? rate;
  final String? symbol;

  const StockValueCol({super.key, this.price, this.rate, this.symbol});

  final double textSpacing = 2;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.sp),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("${price.toString()}$symbol", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: textSpacing),
          Text("${rate.toString()}%" ?? '')
        ],
      ),
    );
  }
}