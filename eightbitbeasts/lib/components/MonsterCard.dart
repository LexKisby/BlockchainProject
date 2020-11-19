part of page_classes;

class MonsterCard extends StatefulWidget {
  final String name;
  final String dna;
  final Image img;
  final int n;
  final String stats;

  const MonsterCard(
      {@required this.name, this.dna, this.img, this.n, this.stats});

  @override
  State createState() => _MonsterCardState();
}

class _MonsterCardState extends State<MonsterCard> {
  Text dna;
  Image img;
  IconData grade = Icons.filter_1_sharp;

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Theme.of(context).primaryColor,
        shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(7))),
        clipBehavior: Clip.antiAlias,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          widget.img,
          Transform(
              transform: Matrix4.translationValues(-6, -15, 0.0),
              child: Container(
                height: 21,
                child: ListTile(
                    title: /*Transform(transform: Matrix4.translationValues(-6, -13, 0.0),   child: */ Text(
                        widget.name,
                        style: TextStyle(
                            fontSize: 20,
                            color:
                                Theme.of(context).textTheme.bodyText1.color))),
              )),
          Transform(
              transform: Matrix4.translationValues(-6, -15, 0.0),
              child: Container(
                  height: 18,
                  child: ListTile(
                    title: Row(children: [
                      Icon(grade,
                          color: Theme.of(context).textTheme.bodyText1.color,
                          size: 18),
                      Text(" Grade " + widget.n.toString() + " Beast",
                          style: TextStyle(
                              fontSize: 14,
                              color:
                                  Theme.of(context).textTheme.bodyText1.color)),
                    ]),
                  ))),
          ListTile(
            title: Center(
                child: Text("stats: " + widget.stats,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText1.color))),
          )
        ]));
  }
}
