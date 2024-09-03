import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:webappview/webview.dart';

class QRscanner extends StatefulWidget {
  const QRscanner({super.key});

  @override
  State<QRscanner> createState() => _QRscannerstate();
}

class _QRscannerstate extends State<QRscanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late ScaffoldMessengerState _smState;
  late QRViewController controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
  }

  @override
  void didChangeDependencies() {
    _smState = ScaffoldMessenger.of(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    controller.dispose();
    _smState.hideCurrentSnackBar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 200.0
        : 250.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        centerTitle: false,
        backgroundColor: const Color.fromRGBO(37, 37, 92, 1.0),
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: const Color.fromARGB(255, 226, 31, 31),
          borderRadius: 5,
          borderLength: 20,
          borderWidth: 5,
          cutOutSize: scanArea,
        ),
        onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.resumeCamera();

    controller.scannedDataStream.listen((scanData) async {
      controller.pauseCamera();

      String scannedCode = scanData.code ?? '';

      if (Platform.isIOS &&
          scanData.format == BarcodeFormat.ean13 &&
          scannedCode.startsWith('0')) {
        scannedCode = scannedCode.replaceFirst('0', '');
      }

      if (scannedCode.isNotEmpty) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WebViewContainer(),
            ),
          );
        }
      }
    });
  }

  void _onPermissionSet(
    BuildContext context,
    QRViewController ctrl,
    bool hasPermission,
  ) {
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Camera Permission')),
      );
    }
  }
  // final GlobalKey qeKey = GlobalKey(debugLabel: 'QR');
  // QRViewController? controller;
  // String scannedcode = '';
  // void _onQRViewCreated(QRViewController controller) {
  //   this.controller = controller;
  //   controller.scannedDataStream.listen((scanData) {
  //     setState(() {
  //       scannedcode = scanData.code!;
  //     });
  //     if (scannedcode == "http://127.0.0.1:4200/tables") {
  //       Navigator.of(context).push(
  //         MaterialPageRoute(
  //           builder: (context) => WebViewContainer(),
  //         ),
  //       );
  //     }
  //   });
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return SafeArea(
  //     child: Scaffold(
  //       body: Column(
  //         children: [
  //           Expanded(
  //             flex: 5,
  //             child: QRView(key: qeKey, onQRViewCreated: _onQRViewCreated),
  //           ),
  //           Expanded(
  //             flex: 1,
  //             child: Center(
  //               child: Text(
  //                 'Scanned Code: $scannedcode',
  //                 style: const TextStyle(fontSize: 18),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // @override
  // void dispose() {
  //   controller?.dispose();
  //   super.dispose();
  // }
}
