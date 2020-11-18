part of page_classes;

class MonsterCard extends StatefulWidget{
  @override
  State createState() => _MonsterCardState();
}

class _MonsterCardState extends State<MonsterCard> {
  Text name;
  Text dna;
  Image img;
  IconData grade = Icons.filter_1_sharp;
  var n = 1;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).primaryColor,
      shape: BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(7))),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset("lib/assets/flutter.png"),
          ListTile(
            leading: Icon(grade, color: Theme.of(context).textTheme.bodyText1.color),
            title: Text("Nidhoggr", style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color)),
            subtitle: Text("Grade " + n.toString() + " Beast", style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color)),
          ),
          ListTile(
            title: Text("stats", style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color))
          )
        ]
      )
    );
  }
}