class CurrencyModel {
  bool? success;
  List<ResultC>? result;

  CurrencyModel({this.success, this.result});

  CurrencyModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['result'] != null) {
      result = <ResultC>[];
      json['result'].forEach((v) {
        result!.add(ResultC.fromJson(v));
      });
    }
  }
}

class ResultC {
  String? code;
  double? buying;

  ResultC({this.code, this.buying});

  ResultC.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    buying = json['buying'].toDouble();
  }
}

class CurrencyChange
{
  bool? isChanged;
  String? newCurrency;
  String? oldCurrency;
  String? symbol;

  CurrencyChange({this.isChanged, this.newCurrency, this.oldCurrency, this.symbol});
}


class DetailsPageCurrency{
  String? symbol;
  double? currencyValue;

  DetailsPageCurrency(this.symbol,this.currencyValue);
}