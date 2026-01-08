import 'package:flutter/material.dart';

class CurrencyConverterMaterialPage extends StatefulWidget{
  const CurrencyConverterMaterialPage({super.key});

  @override
  State<CurrencyConverterMaterialPage> createState() => _CurrencyConverterMaterialPageState();
  }


class _CurrencyConverterMaterialPageState 
    extends State<CurrencyConverterMaterialPage> {
   double result = 0;
   final TextEditingController textEditingController = TextEditingController();
    
    void convert(){
      result = double.parse(textEditingController.text) * 90.10;
      setState((){});
    }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
  
    final border = OutlineInputBorder(
      borderSide: const BorderSide(
        color:Colors.black,
        width: 2.0,
        style: BorderStyle.solid,
        strokeAlign: BorderSide.strokeAlignOutside,
      ),
      borderRadius: BorderRadius.all(Radius.circular(20.0)),
    );

    return Scaffold(
      backgroundColor: Colors.greenAccent,
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: const Text('Currency Converter',style: TextStyle(color: Colors.black),),
        centerTitle: true,
      ),
      body: Center(
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
                color: Colors.black,
              ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(10),
              child: TextField(
                controller: textEditingController,
                style: const TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText : "Enter the amount in USD: ",
                  hintStyle: const TextStyle(
                    color: Colors.black
                    ),
                    prefixIcon: Icon(Icons.monetization_on),
                    prefixIconColor: Colors.black,
                    filled: true,
                    fillColor: Colors.white,
                    focusedBorder: border,
                    enabledBorder: border,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    result = double.parse(textEditingController.text) * 90.10;
                  });
                }, 
                style: ElevatedButton.styleFrom(
                  elevation: 15,
                  backgroundColor: Colors.black45,
                  foregroundColor: Colors.white,
                  fixedSize: const Size(200,50),
                ),
                child: const Text('Convert'),
                ),
            ),
              ]
            ),
        ),
      );
  }
}