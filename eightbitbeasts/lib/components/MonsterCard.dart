part of page_classes;

class MonsterFlipCard extends StatefulWidget {
  final Monster monster;
  final Image img;

  const MonsterFlipCard({@required this.monster, @required this.img});

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
      case 10:
        return Icons.filter_9_plus_sharp;
        break;
    }
    return Icons.error;
  }

  Color getGradeColor(grade) {
    switch (grade) {
      case 1:
        return Colors.amber[400];
        break;
      case 2:
        return Colors.lightBlue[100];
        break;
      case 3:
        return Colors.purple[100];
        break;
      case 4:
        return Colors.lime[300];
        break;
      case 5:
        return Colors.blue;
        break;
      case 6:
        return Colors.deepPurple[700];
        break;
      case 7:
        return Colors.red[300];
        break;
      case 8:
        return Colors.green[200];
        break;
      case 9:
        return Colors.brown[700];
        break;
      case 10:
        return Colors.black;
        break;
    }
    return Colors.black;
  }

  double getElevation(grade) {
    switch (grade) {
      case 1:
        return 30;
        break;
      case 2:
        return 20;
        break;
      case 3:
        return 14;
        break;
      case 4:
        return 13;
        break;
      case 5:
        return 11;
        break;
      case 6:
        return 13;
        break;
      case 7:
        return 7;
        break;
      case 8:
        return 0;
        break;
      case 9:
        return 0;
        break;
      case 10:
        return 0;
        break;
    }
    return 0;
  }

  String splitDna(dna) {
    String str1 = '';
    String str2 = '';
    for (int i = 0; i < 22; i++) {
      if (i % 2 == 0) {
        str1 += dna[i];
      } else {
        str2 += dna[i];
      }
    }
    return (str1 + '\n' + str2);
  }

  @override
  Widget build(BuildContext context) {
    IconData grade = getGradeIcon(widget.monster.grade);
    Color typeColor = getGradeColor(widget.monster.grade);
    double elevation = getElevation(widget.monster.grade);
    var size = MediaQuery.of(context).size;
    final double itemWidth = size.width / 4;
    final double itemHeight = size.height / 30;
    return Container(
      padding: EdgeInsets.all(4),
      child: FlipCard(
          front: Card(
              color: Theme.of(context).primaryColor,
              shadowColor: typeColor,
              elevation: elevation,
              shape: PixelBorder.solid(
                  color: typeColor,
                  pixelSize: 3,
                  borderRadius: BorderRadius.circular(15)),
              clipBehavior: Clip.antiAlias,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Stack(
                  children: [
                    //Container(height: 160, color: Colors.blue),

                    widget.img,

                    Container(
                      height: 170,
                      child: Align(
                        alignment: FractionalOffset(0.1, 0.1),
                        child: Text('#' + widget.monster.id.toString(),
                            style:
                                TextStyle(fontSize: 13, color: Colors.white)),
                      ),
                    ),
                    Container(
                      height: 170,
                      child: Align(
                        alignment: FractionalOffset(0.3, 0.1),
                        child: Text('Lv.' + widget.monster.lvl.toString(),
                            style: TextStyle(
                                fontSize: 13, color: Colors.yellowAccent)),
                      ),
                    ),
                    Container(
                      height: 170,
                      child: Align(
                        alignment: FractionalOffset(0.7, 0.1),
                        child: Text('W' + widget.monster.wins.toString(),
                            style: TextStyle(fontSize: 8, color: Colors.green)),
                      ),
                    ),
                    Container(
                      height: 170,
                      child: Align(
                        alignment: FractionalOffset(0.8, 0.1),
                        child: Text('L' + widget.monster.losses.toString(),
                            style: TextStyle(fontSize: 8, color: Colors.red)),
                      ),
                    ),
                    Container(
                      height: 170,
                      child: Align(
                        alignment: FractionalOffset(0.85, 0.2),
                        child: Text('xp: ' + widget.monster.xp.toString(),
                            style: TextStyle(fontSize: 8, color: Colors.white)),
                      ),
                    ),
                    Container(
                      height: 170,
                      child: Align(
                        alignment: FractionalOffset(0.95, 0.1),
                        child: Text(
                            'r:' + widget.monster.remaining.toInt().toString(),
                            style: TextStyle(
                                fontSize: 8, color: Colors.purpleAccent)),
                      ),
                    ),
                  ],
                ),
                Transform(
                    transform: Matrix4.translationValues(-3, -15, 0.0),
                    child: Container(
                        height: 21,
                        child: ListTile(
                          title: Row(
                            children: [
                              Flexible(
                                  child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(widget.monster.name,
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .color)),
                              )),
                            ],
                          ),
                        ))),
                Transform(
                    transform: Matrix4.translationValues(2, -15, 0.0),
                    child: Container(
                        height: 18,
                        child: ListTile(
                          title: Row(children: [
                            Icon(grade,
                                color:
                                    Theme.of(context).textTheme.bodyText1.color,
                                size: 18),
                            Flexible(
                                child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                  " Grade " +
                                      widget.monster.grade.toString() +
                                      " Beast",
                                  style: TextStyle(
                                      fontSize: 8,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .color)),
                            ))
                          ]),
                        ))),
              ])),
          back: Card(
              color: Theme.of(context).primaryColor,
              elevation: elevation,
              shadowColor: typeColor,
              shape: PixelBorder.solid(
                  pixelSize: 3,
                  color: typeColor,
                  borderRadius: BorderRadius.circular(15)),
              clipBehavior: Clip.antiAlias,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(children: [
                  Padding(
                      padding: EdgeInsets.fromLTRB(10, 8, 4, 4),
                      child: Icon(grade,
                          size: 23,
                          color: Theme.of(context).textTheme.bodyText1.color)),
                  Flexible(
                      child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(widget.monster.name,
                        style: TextStyle(
                            fontSize: 20,
                            color:
                                Theme.of(context).textTheme.bodyText1.color)),
                  )),
                  Container(width: 13)
                ]),
                SizedBox(
                  height: itemHeight * 2.8,
                  width: itemWidth * 1.4,
                  child: Center(
                      child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(splitDna(widget.monster.dna),
                        style: TextStyle(
                            fontSize: 20,
                            color:
                                Theme.of(context).textTheme.bodyText1.color)),
                  )),
                ),
                Transform(
                    transform: Matrix4.translationValues(12, 0, 0),
                    child: Stat(
                        icon: Icons.favorite,
                        iconsize: 24,
                        text: widget.monster.stats.substring(0, 3),
                        fontsize: 17)),
                GridView.count(
                  primary: false,
                  childAspectRatio: 4,
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  children: [
                    Stat(
                        icon: Icons.flash_on,
                        iconsize: 15,
                        text: widget.monster.stats.substring(3, 6),
                        fontsize: 12),
                    Stat(
                        icon: Icons.open_with_sharp,
                        iconsize: 15,
                        text: widget.monster.stats.substring(6, 9),
                        fontsize: 12),
                    Stat(
                        icon: Icons.label_important,
                        iconsize: 15,
                        text: widget.monster.stats.substring(9, 12),
                        fontsize: 12),
                    Stat(
                        icon: Icons.label_important_outline,
                        iconsize: 15,
                        text: widget.monster.stats.substring(12, 15),
                        fontsize: 12),
                    Stat(
                        icon: Icons.looks_sharp,
                        iconsize: 15,
                        text: widget.monster.stats.substring(15, 18),
                        fontsize: 12),
                    Stat(
                        icon: Icons.radio_button_checked_outlined,
                        iconsize: 15,
                        text: widget.monster.stats.substring(18, 21),
                        fontsize: 12),
                    Stat(
                        icon: Icons.switch_right,
                        iconsize: 15,
                        text: widget.monster.stats.substring(21, 24),
                        fontsize: 12),
                    Stat(
                        icon: Icons.emoji_objects,
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
    @required this.text,
    @required this.icon,
    @required this.fontsize,
    @required this.iconsize,
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
              transform: Matrix4.translationValues(0, 0, 0),
              child: Icon(icon,
                  size: iconsize,
                  color: Theme.of(context).textTheme.bodyText1.color))),
      Expanded(
          child: Transform(
              transform: Matrix4.translationValues(-4, 0, 0),
              child: Text(text,
                  style: TextStyle(
                      fontFamily: "PressStart2P",
                      fontSize: fontsize,
                      color: Theme.of(context).textTheme.bodyText1.color)))),
    ]));
  }
}

class MonsterPicSmall extends StatelessWidget {
  final Monster data;

  MonsterPicSmall({@required this.data});

  Color getGradeColor(grade) {
    switch (grade) {
      case 1:
        return Colors.amber[400];
        break;
      case 2:
        return Colors.lightBlue[100];
        break;
      case 3:
        return Colors.purple[100];
        break;
      case 4:
        return Colors.lime[300];
        break;
      case 5:
        return Colors.blue;
        break;
      case 6:
        return Colors.deepPurple[700];
        break;
      case 7:
        return Colors.red[300];
        break;
      case 8:
        return Colors.green[200];
        break;
      case 9:
        return Colors.brown[700];
        break;
      case 0:
        return Colors.black;
        break;
    }
    return Colors.black;
  }

  @override
  build(BuildContext context) {
    return Card(
        color: Theme.of(context).primaryColor,
        shape: PixelBorder.solid(
          color: getGradeColor(data.grade),
          pixelSize: 1,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Stack(children: [
          data.img,
          Container(
            height: 50,
            child: Align(
              alignment: FractionalOffset(0.1, 0.2),
              child: Text('#' + data.id.toString(),
                  style: TextStyle(fontSize: 6, color: Colors.white)),
            ),
          ),
          Container(
            height: 50,
            child: Align(
              alignment: FractionalOffset(0.9, 0.2),
              child: Text('r:' + data.remaining.toInt().toString(),
                  style: TextStyle(fontSize: 6, color: Colors.redAccent)),
            ),
          ),
        ]));
  }
}
