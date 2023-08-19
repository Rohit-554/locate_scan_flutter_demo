import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class BarCodeScanner extends StatefulWidget {
  const BarCodeScanner({Key? key}) : super(key: key);

  @override
  _BarCodeScannerState createState() => _BarCodeScannerState();
}

class _BarCodeScannerState extends State<BarCodeScanner> {
  String result = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Product Id/link : " + result,
            style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w400,fontFamily: "Roboto")),
        ElevatedButton(
          onPressed: () async {
            var res = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SimpleBarcodeScannerPage(),
                ));
            setState(() {
              if (res is String) {
                result = res;
              }
              print("result is " + result);
            });
          },
          child: const Text('Open Scanner'),
        )
      ],
    );
  }
}
