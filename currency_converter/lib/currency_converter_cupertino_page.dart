import 'package:flutter/cupertino.dart';

class CurrencyConverterCupertinoPage extends StatefulWidget {
  const CurrencyConverterCupertinoPage({super.key});

  @override
  State <CurrencyConverterCupertinoPage> createState() =>  _CurrencyConverterCupertinoPageState();
}

class _CurrencyConverterCupertinoPageState extends State<CurrencyConverterCupertinoPage> {

double result = 0;
   final TextEditingController textEditingController = TextEditingController();
    
    void convert(){
      result = double.parse(textEditingController.text) * 90.10;
      setState((){});
    }

    @override
  Widget build(BuildContext context){
  
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemMint,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemGreen,
        middle: Text('Currency Converter',style: TextStyle(color: CupertinoColors.black),),
      ),
      child: Center(
        child: Column (
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(10),
              color: const Color.fromARGB(255, 200, 236, 227),
              child:  Text(
                ' INR ${result != 0 ?result.toStringAsFixed(2) : result.toStringAsFixed(0)}',
                style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.black,
              ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(10),
              child: CupertinoTextField(
                controller: textEditingController,
                style: const TextStyle(
                  color: CupertinoColors.black,
                ),
                decoration: BoxDecoration(
                  color: CupertinoColors.extraLightBackgroundGray,
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(5),
                ),
                placeholder: 'Enter amuont in USD',
                prefix:const Icon(CupertinoIcons.money_dollar),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: CupertinoButton(
                onPressed: convert,
                color:CupertinoColors.black,
                child: const Text('Convert'),
                ),
            ),
          ],
        ),
      ),
    );
  }
}