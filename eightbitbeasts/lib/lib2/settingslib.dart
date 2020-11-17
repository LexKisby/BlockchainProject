part of page_classes;

class SettingsContent extends StatefulWidget {
  @override
  State createState() => SettingsContentState();
}

class SettingsContentState extends State<SettingsContent> {
  var _useCustomTime = false;
  DateTime customDay = DateTime.parse("2020-07-20");
  TimeOfDay customTime = TimeOfDay.fromDateTime(DateTime.parse("2020-07-20 20:18:04Z"));
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
      body: Center(
        child: ListView(
                padding: const EdgeInsets.only(bottom: 88),
                children: [
                  ListTile(
                    title: Text("Time Control"),
                    trailing: Text("Using: " +  DateFormat("dd/MM/yyyy").format(currentDay) +"  "+ currentTime.format(context)),
                  ),
                  SwitchListTile(
                    title: Text("Use Custom Time"),
                    value: _useCustomTime,
                    onChanged: _onUseCustomTimeChanged,
                  ),
                  ListTile(

                    title: Text("Pick Custom Time: ")
                  ),
                     Row(
                      children: <Widget>[
                        Expanded(child:IconButton(icon: Icon(Icons.calendar_today), onPressed: () {
                            _showDatePicker();
                        })),
                        Expanded(child:IconButton(icon: Icon(Icons.schedule), onPressed: () {
                          _showTimePicker();
                        })),
                        const Divider(
                          color: Colors.black,
                          height: 4,
                          thickness: 4,
                        )
                        /*IconButton(
                          icon: Icon(Icons.calendar_today),
                          /*onPressed: () {
                            _showDatePicker();
                          },*/
                        ),
                        IconButton(
                          icon: Icon(Icons.schedule),
                          /*onPressed: () {
                            _showTimePicker();
                          }*/
                        )
                      */]
                    )
                
                 ]),
            )   
    );
  }
} 