import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_epurchase_test/saver/saver.dart';
import 'package:flutter_epurchase_test/saver/saver_keys.dart';

void main() {
  runApp(MyApp());
}

FirebaseAnalytics analytics = FirebaseAnalytics();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _isEPurchase = true;
  List<String> _itemName = [
    'Soto',
    'Bakso',
    'Nasi Goreng',
  ];
  Random _r = Random();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Saver()
          .retrieve(SaverKeys.counter)
          .then((value) => setState(() => _counter = value ?? 0))
          .catchError((e) => print('Not found'));
    });
    super.initState();
  }

  void _purchase() async {
    // FirebaseAnalytics analytics = FirebaseAnalytics();

    // Log Purchase
    await analytics.logEvent(
      name: 'purchase',
      parameters: filterOutNulls(<String, dynamic>{
        /// The unique identifier of a transaction (String).
        'transaction_id': _r.nextInt(1000000).toString(),

        // /// A product affiliation to designate a supplying company or brick and mortar store location (String).
        // 'affiliation': null,

        // /// Coupon code used for a purchase (String).
        // 'coupon': null,

        /// Currency of the purchase or items associated with the event, in 3-letter ISO_4217 format (String).
        'currency': 'IDR',

        /// The list of items involved in the transaction.
        // 'items': _itemName,

        // /// Shipping cost associated with a transaction (double).
        // 'shipping': 20000,

        // /// Tax cost associated with a transaction (double).
        // 'tax': 10000,

        /// A context-specific numeric value which is accumulated automatically for each event type.
        'value': 100000,

        /// Customized parameter
        'barang': _itemName.toString(),

        /// Customized parameter
        'jumlah': (_counter / 3).floor() + 1,
      }),
    );
    setState(() {
      _counter++;
      print('Saving counter - Purchase');
      Saver().save(SaverKeys.counter, _counter);
    });
  }

  void _epurchase() async {
    // FirebaseAnalytics analytics = FirebaseAnalytics();

    // Log E-Purchase
    await analytics.logEcommercePurchase(
      currency: 'IDR',
      // shipping: 20000,
      // tax: 10000,
      value: 100000, // Price
      transactionId: _r.nextInt(1000000).toString(),
    );
    setState(() {
      _counter++;
      print('Saving counter - E-commerce purchase');
      Saver().save(SaverKeys.counter, _counter);
    });
  }

  Map<String, dynamic> filterOutNulls(Map<String, dynamic> parameters) {
    final Map<String, dynamic> filtered = <String, dynamic>{};
    parameters.forEach((String key, dynamic value) {
      if (value != null) {
        filtered[key] = value;
      }
    });
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You purchase many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            SizedBox(height: 12),
            Switch(
                value: _isEPurchase,
                onChanged: (newVal) {
                  setState(() {
                    _isEPurchase = newVal;
                  });
                })
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isEPurchase ? _epurchase : _purchase,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
