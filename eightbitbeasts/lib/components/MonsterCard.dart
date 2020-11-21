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
  final Monster monster;
  final Image img;

  const MonsterFlipCard({@required this.monster, this.img});

  @override
  State createState() => _MonsterFlipCardState();
}

class _MonsterFlipCardState extends State<MonsterFlipCard> {
  IconData getGradeIcon(grade) {
    switch (grade) {
      case 1:
        return Icons.filter_1_sharp;
        break;
      case 2:
        return Icons.filter_2_sharp;
        break;
      case 3:
        return Icons.filter_3_sharp;
        break;
      case 4:
        return Icons.filter_4_sharp;
        break;
      case 5:
        return Icons.filter_5_sharp;
        break;
      case 6:
        return Icons.filter_6_sharp;
        break;
      case 7:
        return Icons.filter_7_sharp;
        break;
      case 8:
        return Icons.filter_8_sharp;
        break;
      case 9:
        return Icons.filter_9_sharp;
        break;
      case 0:
        return Icons.filter_9_plus_sharp;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    IconData grade = getGradeIcon(widget.monster.grade);
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
                          title: Text(widget.monster.name,
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
                            Text(
                                " Grade " +
                                    widget.monster.grade.toString() +
                                    " Beast",
                                style: TextStyle(
                                    fontSize: 9,
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
                      child: Icon(grade,
                          color: Theme.of(context).textTheme.bodyText1.color)),
                  Transform(
                      transform: Matrix4.translationValues(4, 0, 0),
                      child: Text(widget.monster.name,
                          style: TextStyle(
                              fontSize: 20,
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
                        text: widget.monster.stats.substring(0, 3),
                        fontsize: 17)),
                GridView.count(
                  primary: false,
                  childAspectRatio: itemWidth / itemHeight,
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  children: [
                    Stat(
                        icon: Icons.open_with_sharp,
                        iconsize: 15,
                        text: widget.monster.stats.substring(3, 6),
                        fontsize: 12),
                    Stat(
                        icon: Icons.format_align_justify,
                        iconsize: 15,
                        text: widget.monster.stats.substring(6, 9),
                        fontsize: 12),
                    Stat(
                        icon: Icons.wallet_giftcard,
                        iconsize: 15,
                        text: widget.monster.stats.substring(9, 12),
                        fontsize: 12),
                    Stat(
                        icon: Icons.pages_outlined,
                        iconsize: 15,
                        text: widget.monster.stats.substring(12, 15),
                        fontsize: 12),
                    Stat(
                        icon: Icons.data_usage_sharp,
                        iconsize: 15,
                        text: widget.monster.stats.substring(15, 18),
                        fontsize: 12),
                    Stat(
                        icon: Icons.amp_stories_sharp,
                        iconsize: 15,
                        text: widget.monster.stats.substring(18, 21),
                        fontsize: 12),
                    Stat(
                        icon: Icons.mail_outline,
                        iconsize: 15,
                        text: widget.monster.stats.substring(21, 24),
                        fontsize: 12),
                    Stat(
                        icon: Icons.radio_button_checked_outlined,
                        iconsize: 15,
                        text: widget.monster.stats.substring(24, 27),
                        fontsize: 12),
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
              transform: Matrix4.translationValues(0, 0, 0),
              child: Text(text,
                  style: TextStyle(
                      fontFamily: "PressStart2P",
                      fontSize: fontsize,
                      color: Theme.of(context).textTheme.bodyText1.color)))),
    ]));
  }
}
