import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'PageLibrary.dart';

void main() {
  runApp(MyApp());
}

/*  All providers are initialised in main */
//myWalletProvider will provide the wallet details for transactions, tho currently
// will just store an address
final myWalletProvider = ChangeNotifierProvider<MyWalletChangeNotifier>((ref) {
  return MyWalletChangeNotifier();
});

final myMonstersProvider =
    ChangeNotifierProvider<MyMonstersChangeNotifier>((ref) {
  return MyMonstersChangeNotifier();
});

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
        child: MaterialApp(
      title: '8Bit Beasts',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.

        primaryColor: const Color(0xff1d1d1d),
        accentColor: const Color(0xffee5622),
        canvasColor: const Color(0xff121212),
        backgroundColor: const Color(0xff362234),
        textTheme: TextTheme(
          bodyText1: TextStyle(
            color: const Color(0xfffef0d1),
          ),
        ),
      ),
      home: Root(),
    ));
  }
}

class Root extends StatefulWidget {
  @override
  RootState createState() => RootState();
}

class RootState extends State<Root> {
  int _selectedIndex = 0;
  PageController _controller = PageController(
    initialPage: 0,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        children: [
          InventoryPage(),
          AuctionPage(),
          CapturePage(),
          HatchingPage(),
          SettingsPage()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.library_books_sharp), label: "Inventory"),
          BottomNavigationBarItem(
              icon: Icon(Icons.gavel_sharp), label: "Auctions"),
          BottomNavigationBarItem(
              icon: Icon(Icons.security_sharp), label: "Capture"),
          BottomNavigationBarItem(
              icon: Icon(Icons.flare_sharp), label: "Hatch"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_applications_sharp), label: "Settings")
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).accentColor,
        backgroundColor: Theme.of(context).primaryColor,
        unselectedItemColor: Theme.of(context).textTheme.bodyText1.color,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class InventoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Inventory"),
        ),
        body: InventoryContent());
  }
}

class AuctionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Market")),
        body: Center(child: Text("sup")));
  }
}

class CapturePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Capture")),
        body: Center(child: Text("cool beans")));
  }
}

class HatchingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Hatch")),
        body: Center(child: Text("whooop")));
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: SettingsContent(),
    );
  }
}
