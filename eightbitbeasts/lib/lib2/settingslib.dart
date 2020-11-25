part of page_classes;

class SettingsContent extends StatefulWidget {
  @override
  State createState() => SettingsContentState();
}

class SettingsContentState extends State<SettingsContent> {
  var _useCustomTime = false;
  DateTime customDay = DateTime.parse("2020-07-20");
  TimeOfDay customTime =
      TimeOfDay.fromDateTime(DateTime.parse("2020-07-20 20:18:04Z"));
  DateTime currentDay = DateTime.now();
  TimeOfDay currentTime = TimeOfDay.fromDateTime(DateTime.now());

  void _onUseCustomTimeChanged(bool value) {
    setState(() {
      _useCustomTime = value;
      if (value) {
        currentTime = customTime;
        currentDay = customDay;
      } else {
        currentTime = TimeOfDay.fromDateTime(DateTime.now());
        currentDay = DateTime.now();
      }
    });
  }

  Future<void> _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: customDay,
      firstDate: DateTime(2020, 1),
      lastDate: DateTime(2100, 1),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            fontFamily: 'PressStart2P',
            textTheme: TextTheme(
              headline4: TextStyle(fontSize: 18),
            ),
            accentColor: Theme.of(context).accentColor,
            primaryColor: Theme.of(context).primaryColor,
            colorScheme: ColorScheme(
              primary: Theme.of(context).accentColor,
              primaryVariant: Theme.of(context).primaryColor,
              onPrimary: Theme.of(context).textTheme.bodyText1.color,
              secondary: Theme.of(context).backgroundColor,
              onSecondary: Theme.of(context).textTheme.bodyText1.color,
              secondaryVariant: Theme.of(context).backgroundColor,
              error: Colors.red,
              onError: Colors.white,
              surface: Theme.of(context).backgroundColor,
              onSurface: Theme.of(context).textTheme.bodyText1.color,
              background: Colors.black,
              onBackground: Theme.of(context).textTheme.bodyText1.color,
              brightness: Brightness.dark,
            ),
          ),
          child: child,
        );
      },
    );
    if (picked != null && picked != customDay) {
      setState(() {
        customDay = picked;
        _onUseCustomTimeChanged(_useCustomTime);
      });
    }
  }

  Future<void> _showTimePicker() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: customTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            fontFamily: 'PressStart2P',
            textTheme: TextTheme(
              headline2: TextStyle(fontSize: 32),
            ),
            accentColor: Theme.of(context).accentColor,
            primaryColor: Theme.of(context).primaryColor,
            colorScheme: ColorScheme(
              primary: Theme.of(context).accentColor,
              primaryVariant: Theme.of(context).primaryColor,
              onPrimary: Theme.of(context).textTheme.bodyText1.color,
              secondary: Theme.of(context).backgroundColor,
              onSecondary: Theme.of(context).textTheme.bodyText1.color,
              secondaryVariant: Theme.of(context).backgroundColor,
              error: Colors.red,
              onError: Colors.white,
              surface: Theme.of(context).backgroundColor,
              onSurface: Theme.of(context).textTheme.bodyText1.color,
              background: Colors.black,
              onBackground: Theme.of(context).textTheme.bodyText1.color,
              brightness: Brightness.dark,
            ),
          ),
          child: child,
        );
      },
    );
    if (picked != null && picked != customTime) {
      setState(() {
        customTime = picked;
        _onUseCustomTimeChanged(_useCustomTime);
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: <Widget>[
      Container(
          padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
          child: Card(
            shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(7))),
            color: Theme.of(context).primaryColor,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(
                title: Text(
                  "Time Control",
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyText1.color),
                ),
                subtitle: Text(
                  "Using: " +
                      DateFormat("dd/MM/yyyy").format(currentDay) +
                      "  " +
                      currentTime.format(context),
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyText1.color,
                      fontSize: 12),
                ),
              ),
              Divider(),
              SwitchListTile(
                title: Text("Use Custom Time:",
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText1.color)),
                value: _useCustomTime,
                onChanged: _onUseCustomTimeChanged,
              ),
              Divider(),
              ListTile(
                  title: Text("Pick Custom Time: ",
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1.color))),
              Row(children: <Widget>[
                Expanded(
                    child: IconButton(
                        color: Theme.of(context).textTheme.bodyText1.color,
                        icon: Icon(Icons.calendar_today_sharp),
                        onPressed: () {
                          _showDatePicker();
                        })),
                Expanded(
                    child: IconButton(
                        color: Theme.of(context).textTheme.bodyText1.color,
                        icon: Icon(Icons.history_sharp),
                        onPressed: () {
                          _showTimePicker();
                        })),
              ])
            ]),
          )),
      SettingsWalletCard(),
    ]));
  }
}

class SettingsWalletCard extends ConsumerWidget {
  @override
  build(BuildContext context, ScopedReader watch) {
    final address = watch(myWalletProvider);
    return Container(
        padding: EdgeInsets.all(4),
        child: Card(
            shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(7))),
            color: Theme.of(context).primaryColor,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(
                  title: Text("Wallet Credentials",
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1.color)),
                  subtitle: Text("Change wallet details in metamask",
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1.color))),
              ListTile(
                  title: Text("Current Address: ${address.address}",
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1.color))),
              FloatingActionButton(onPressed: () => address.increment())
            ])));
  }
}
