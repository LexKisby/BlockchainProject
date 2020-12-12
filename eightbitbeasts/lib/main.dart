import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:pixel_border/pixel_border.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
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

final myEthDataProvider = ChangeNotifierProvider<EthChangeNotifier>((ref) {
  return EthChangeNotifier();
});

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
        child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '8Bit Beasts',
      theme: ThemeData(
        fontFamily: 'PressStart2P',
        primaryColor: const Color(0xff1d1d1d),
        accentColor: const Color(0xffee5622),
        canvasColor: const Color(0xff121212),
        backgroundColor: const Color(0xff362234),
        buttonTheme: ButtonThemeData(
            shape: PixelBorder(
          pixelSize: 5,
          borderRadius: BorderRadius.circular(10),
        )),
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
      _controller.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  void pageChanged(index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        onPageChanged: (index) {
          pageChanged(index);
        },
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
              icon: Icon(Icons.gavel_sharp), label: "Market"),
          BottomNavigationBarItem(
              icon: Icon(Icons.security_sharp), label: "Battle"),
          BottomNavigationBarItem(
              icon: Icon(Icons.flare_sharp), label: "Extract"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_applications_sharp), label: "Settings")
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).accentColor,
        backgroundColor: Theme.of(context).primaryColor,
        unselectedItemColor: Theme.of(context).textTheme.bodyText1.color,
        onTap: _onItemTapped,
        selectedFontSize: 7,
        unselectedFontSize: 7,
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
          actions: <Widget>[
            Column(
              children: [InitWidget()],
            )
          ],
        ),
        body: InventoryContent());
  }
}

class AuctionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
              title: Text("Market"),
              actions: [
                Column(children: [
                  Padding(padding: EdgeInsets.all(2)),
                  Ruby(),
                  Essence()
                ])
              ],
              bottom: TabBar(
                isScrollable: false,
                tabs: [
                  Tab(text: "auction"),
                  Tab(text: "extract"),
                  Tab(text: "mine"),
                ],
              )),
          body: TabBarView(
            children: [
              AuctionContent(),
              DonorContent(),
              MyMarketContent(),
            ],
          ),
        ));
  }
}

class CapturePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
              title: Text("Battle"),
              actions: [
                Column(
                  children: [
                    Padding(padding: EdgeInsets.all(2)),
                    Ruby(),
                    Essence()
                  ],
                ),
              ],
              bottom: TabBar(
                tabs: [
                  Tab(text: "capture"),
                  Tab(text: "PvP"),
                  Tab(text: "leaderboards"),
                ],
              )),
          body: TabBarView(
            children: [
              CaptureContent(),
              PvPContent(),
              LeaderBoards(),
            ],
          ),
        ));
  }
}

class HatchingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Hatch"),
          actions: [
            Column(
              children: [
                Padding(padding: EdgeInsets.all(2)),
                Ruby(),
                Essence()
              ],
            )
          ],
        ),
        body: Center(child: Text("whooop")));
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        actions: [
          Column(children: [
            Padding(padding: EdgeInsets.all(2)),
            Ruby(),
            Essence()
          ])
        ],
      ),
      body: SettingsContent(),
    );
  }
}
