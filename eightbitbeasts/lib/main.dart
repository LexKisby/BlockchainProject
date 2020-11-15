import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        primarySwatch: Colors.blue,
      ),
      home: Root(),
    );
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
  void dispose(){
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
          icon: Icon(Icons.library_books),
          label: "Inventory"
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.gavel),
            label: "Auctions"
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.security),
            label: "Capture"
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.flare),
            label: "Hatch"
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.settings_applications),
            label: "Settings"
          )

        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.redAccent[700],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

/*
  @override 
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      children: [
        InventoryPage(),
        AuctionPage(),
        CapturePage(),
        HatchingPage(),
        SettingsPage()
      ],
    );
  }*/
}

class InventoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inventory"),),
      body: Center(child: Text("yo"))
    );
    
  }
} 

class AuctionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: Text("Market")
    ),
    body: Center(child: Text("sup"))
    );
  }
}

class CapturePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text("Capture")
    ),
    body: Center(child: Text("cool beans"))
    );
  }
}

class HatchingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text("Hatch")
    ), body: Center(child: Text("whooop"))
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text("Settings")
      ),
      body: Center(child: Text("hmm"))
    );
  }
}