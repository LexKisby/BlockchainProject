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
                widget.img,
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
                    child: Flexible(
                        child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(splitDna(widget.monster.dna),
                          style: TextStyle(
                              fontSize: 20,
                              color:
                                  Theme.of(context).textTheme.bodyText1.color)),
                    )),
                  ),
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
      child: data.img,
    );
  }
}
