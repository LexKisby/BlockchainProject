
part of page_classes;

class SettingsContent extends StatefulWidget {
  @override
  State createState() => SettingsContentState();
}

class SettingsContentState extends State<SettingsContent> {
  var _useCustomTime = false;
  var customTime = DateTime.parse("1969-07-20 20:18:04Z");
  var time = DateTime.now();
  

  void _onUseCustomTimeChanged(bool value) {
    setState(() {
      _useCustomTime = value;
      if (value) {
        time = customTime;
      } else {
        time = DateTime.now();
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          SwitchListTile(
              title: Text("Custom Time"),
              value: _useCustomTime,
              onChanged: _onUseCustomTimeChanged,
            ),
            ListTile(
              title: Text(DateFormat("dd/MM/yyyy —   HH:mm").format(time)),

            )
      ],)
    );
  }
}