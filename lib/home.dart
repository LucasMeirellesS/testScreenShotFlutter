import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:testescreenshot/sinature.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // initialize the signature controller
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 1,
    penColor: Colors.red,
    exportBackgroundColor: Colors.transparent,
    exportPenColor: Colors.black,
    onDrawStart: () => log('onDrawStart called!'),
    onDrawEnd: () => log('onDrawEnd called!'),
  );

  bool showSig = true;

  Uint8List? dataImage;

  @override
  void initState() {
    super.initState();
    _controller
      ..addListener(() => log('Value changed'))
      ..onDrawEnd = () => setState(
            () {
              // setState for build to update value of "empty label" in gui
            },
          );
  }

  @override
  void dispose() {
    // IMPORTANT to dispose of the controller
    _controller.dispose();
    super.dispose();
  }

  Future<void> exportImage(BuildContext context) async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          key: Key('snackbarPNG'),
          content: Text('No content'),
        ),
      );
      return;
    }

    final Uint8List? data =
        await _controller.toPngBytes(height: 1000, width: 1000);
    if (data == null) {
      return;
    }

    if (!mounted) return;

    setState(() {
      dataImage = data;
    });
  }

  void onShowSig() {
    setState(() {
      showSig = true;
    });
  }

  void ofShowSig() {
    setState(() {
      showSig = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signature Demo'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //SIGNATURE CANVAS
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: showSig
                ? Signature(
                    key: const Key('signature'),
                    controller: _controller,
                    height: 300,
                    backgroundColor: Colors.grey[300]!,
                  )
                : SizedBox(
                    height: 300,
                    child: Center(
                      child: Container(
                        color: Colors.grey[300],
                        child: dataImage != null
                            ? Image.memory(dataImage!)
                            : Image.asset("assets/baixados.jpeg"),
                      ),
                    )),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          decoration: const BoxDecoration(color: Colors.black),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              IconButton(
                key: const Key('BackToSig'),
                icon: const Icon(Icons.arrow_back),
                color: Colors.blue,
                onPressed: () => onShowSig(),
                tooltip: 'Show Signature',
              ),

              //SHOW EXPORTED IMAGE IN NEW ROUTE
              IconButton(
                key: const Key('exportPNG'),
                icon: const Icon(Icons.image),
                color: Colors.blue,
                onPressed: () {
                  exportImage(context);
                  ofShowSig();
                },
                tooltip: 'Export Image',
              ),
              //CLEAR CANVAS
              IconButton(
                key: const Key('clear'),
                icon: const Icon(Icons.clear),
                color: Colors.blue,
                onPressed: () {
                  setState(() => _controller.clear());
                },
                tooltip: 'Clear',
              ),
              // STOP Edit
            ],
          ),
        ),
      ),
    );
  }
}
