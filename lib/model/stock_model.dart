class StockModel {
  List<Result>? result;

  StockModel({this.result});

  StockModel.fromJson(Map<String, dynamic> json) {
    if (json['result'] != null) {
      result = <Result>[];
      json['result'].forEach((v) {
        result!.add(Result.fromJson(v));
      });
      sortResultList();
    }
  }

  void sortResultList()
  {
    result?.sort((a,b) => a.code!.compareTo(b.code!));
  }
}

class Result {
  double? lastprice;
  double? rate;
  String? text;
  String? code;
  String? hacim;

  Result({this.lastprice, this.rate, this.text, this.code, this.hacim});

  Result.fromJson(Map<String, dynamic> json) {
    lastprice = json['lastprice'].toDouble();
    rate = json['rate'].toDouble();
    text = json['text'];
    code = json['code'];
    hacim = json['hacimstr'];

  }
}

