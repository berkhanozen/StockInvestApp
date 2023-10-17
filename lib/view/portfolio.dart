import 'package:flutter/material.dart';
import 'package:fonyat/theme.dart';
import 'package:sizer/sizer.dart';
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

class Portfolio extends StatefulWidget {
  const Portfolio({Key? key}) : super(key: key);

  @override
  State<Portfolio> createState() => _PortfolioState();
}

class _PortfolioState extends State<Portfolio> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 2.h),
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: Container(
                      color: Colors.black45,
                        child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("PORTFÖY", style: TextStyle(fontSize: 26.sp), textAlign: TextAlign.center),
                    ))),
                  ],
                ), SizedBox(height: 2.h,),
                GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                    itemCount: 1,
                    itemBuilder: (BuildContext ctx, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: darkThemeData().primaryColor,
                            borderRadius: BorderRadius.circular(15)),
                        child: Text("ADEL", style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
                      );
                    }),
              ],
            )
        ),
      ),
    );
  }
}
