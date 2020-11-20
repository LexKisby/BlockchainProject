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

class MonsterFlipCard extends StatefulWidget {
  final String name;
  final String dna;
  final Image img;
  final int n;
  final String stats;

  const MonsterFlipCard(
      {@required this.name, this.dna, this.img, this.n, this.stats});

  @override
  State createState() => _MonsterFlipCardState();
}

class _MonsterFlipCardState extends State<MonsterFlipCard> {
  Text dna;
  Image img;
  IconData grade = Icons.filter_1_sharp;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemWidth = size.width / 4;
    final double itemHeight = size.height / 30;
    return Container(
      padding: EdgeInsets.all(4),
      child: FlipCard(
          front: Card(
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
                          title: Text(widget.name,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .color))),
                    )),
                Transform(
                    transform: Matrix4.translationValues(-6, -15, 0.0),
                    child: Container(
                        height: 18,
                        child: ListTile(
                          title: Row(children: [
                            Icon(grade,
                                color:
                                    Theme.of(context).textTheme.bodyText1.color,
                                size: 18),
                            Text(" Grade " + widget.n.toString() + " Beast",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .color)),
                          ]),
                        ))),
              ])),
          back: Card(
              color: Theme.of(context).primaryColor,
              shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(7))),
              clipBehavior: Clip.antiAlias,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(children: [
                  Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.filter_1_sharp,
                          color: Theme.of(context).textTheme.bodyText1.color)),
                  Transform(
                      transform: Matrix4.translationValues(4, 0, 0),
                      child: Text(widget.name,
                          style: TextStyle(
                              fontSize: 25,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .color))),
                ]),
                SizedBox(
                  height: itemHeight * 2.8,
                  width: itemWidth * 2,
                  child: Center(
                      child: Transform(
                          transform: Matrix4.translationValues(0, 20, 0),
                          child: Divider(
                            color: Colors.white,
                          ))),
                ),
                Transform(
                    transform: Matrix4.translationValues(12, 0, 0),
                    child: Stat(
                        icon: Icons.hd_sharp,
                        iconsize: 24,
                        text: "99",
                        fontsize: 20)),
                GridView.count(
                  primary: false,
                  childAspectRatio: itemWidth / itemHeight,
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  children: [
                    Stat(
                        icon: Icons.open_with_sharp,
                        iconsize: 15,
                        text: "1",
                        fontsize: 15),
                    Stat(
                        icon: Icons.format_align_justify,
                        iconsize: 15,
                        text: "2",
                        fontsize: 15),
                    Stat(
                        icon: Icons.wallet_giftcard,
                        iconsize: 15,
                        text: "7",
                        fontsize: 15),
                    Stat(
                        icon: Icons.pages_outlined,
                        iconsize: 15,
                        text: "4",
                        fontsize: 15),
                    Stat(
                        icon: Icons.data_usage_sharp,
                        iconsize: 15,
                        text: "1",
                        fontsize: 15),
                    Stat(
                        icon: Icons.amp_stories_sharp,
                        iconsize: 15,
                        text: "2",
                        fontsize: 15),
                    Stat(
                        icon: Icons.mail_outline,
                        iconsize: 15,
                        text: "3",
                        fontsize: 15),
                    Stat(
                        icon: Icons.radio_button_checked_outlined,
                        iconsize: 15,
                        text: "999",
                        fontsize: 15),
                  ],
                ),
              ]))),
    );
  }
}

class Stat extends StatelessWidget {
  Stat({
    this.text,
    this.icon,
    this.fontsize,
    this.iconsize,
  });
  final String text;
  final IconData icon;
  final double fontsize;
  final double iconsize;

  @override
  build(BuildContext context) {
    return Center(
        child: Row(children: [
      Expanded(
          child: Transform(
              transform: Matrix4.translationValues(3, 0, 0),
              child: Icon(icon,
                  size: iconsize,
                  color: Theme.of(context).textTheme.bodyText1.color))),
      Expanded(
          child: Transform(
              transform: Matrix4.translationValues(6, 0, 0),
              child: Text(text,
                  style: TextStyle(
                      fontSize: fontsize,
                      color: Theme.of(context).textTheme.bodyText1.color)))),
    ]));
  }
}
