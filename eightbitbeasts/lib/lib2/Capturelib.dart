part of page_classes;

class LeaderBoards extends ConsumerWidget {
  build(BuildContext context, ScopedReader watch) {
    return Center(child: Text("to be server based"));
  }
}

class DungeonBox extends ConsumerWidget {
  DungeonBox({this.pos});
  final pos;

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
        return 20;
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

  String text(pos) {
    switch (pos) {
      case 1:
        return ' do you dare enter the Dungeon?\n\ntreasure awaits those who seek it';
        break;
      case 2:
        return 'For those a little braver';
        break;
      case 3:
        return 'Ambition and risk go hand in hand';
        break;
      case 4:
        return 'For warriors that know no fear';
        break;
      case 5:
        return 'The next stepping stone of strength';
        break;
      case 6:
        return 'For heroes searching for glory';
        break;
      case 7:
        return 'Beyond every peak is another,\n\n ever taller';
        break;
      case 8:
        return 'For legends who have reached\n\nthe limits under heaven';
        break;
      case 9:
        return 'Transcendence is the final wall';
        break;
      case 10:
        return 'For Gods that make even\n\n dragons kneel before them';
    }
    return ' do you dare enter the Dungeon?\n\ntreasure awaits those who seek it';
  }

  Image image(pos) {}

  build(BuildContext context, ScopedReader watch) {
    final info = watch(myEthDataProvider);
    final size = MediaQuery.of(context).size;

    double l = size.width / 7;
    if (pos == 1) l = size.width / 4;
    return Column(
      children: [
        Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Card(
                elevation: getElevation(11 - pos),
                shadowColor: getGradeColor(11 - pos),
                shape: PixelBorder.solid(
                    color: getGradeColor(11 - pos),
                    pixelSize: 3,
                    borderRadius: BorderRadius.circular(15)),
                clipBehavior: Clip.antiAlias,
                color: Theme.of(context).primaryColor,
                child: Row(
                  children: [
                    Container(
                      height: l,
                      width: l,
                      color: Colors.red,
                    ),
                    Spacer(),
                    Column(children: [
                      Text(text(pos),
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText1.color)),
                      Container(height: 20),
                      ElevatedButton(
                          child: Text('enter'),
                          onPressed: () {
                            info.dungeonSelected = pos;
                            info.openSelector(context, 8);
                          }),
                    ]),
                    Spacer()
                  ],
                )))
      ],
    );
  }
}

class CaptureContent extends StatelessWidget {
  build(BuildContext context) {
    return ListView(
      children: [
        DungeonBox(pos: 1),
        DungeonBox(pos: 2),
        DungeonBox(pos: 3),
        DungeonBox(pos: 4),
        DungeonBox(pos: 5),
        DungeonBox(pos: 6),
        DungeonBox(pos: 7),
        DungeonBox(pos: 8),
        DungeonBox(pos: 9),
        DungeonBox(pos: 10),
      ],
    );
  }
}

class PvPContent extends ConsumerWidget {
  build(BuildContext context, ScopedReader watch) {
    final info = watch(myEthDataProvider);
    return RefreshIndicator(
      child: ListView(
        children: [
          Container(
            height: 50,
            child: Center(
                child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).backgroundColor),
              onPressed: () {
                info.openSelector(context, 9);
                //print("add extract");
              },
              child: Text("send challenge",
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyText1.color)),
            )),
          ),
          Container(
            height: 40,
            child: Card(
                color: Theme.of(context).primaryColor,
                shape: PixelBorder.solid(
                  color: Theme.of(context).backgroundColor,
                  pixelSize: 1,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                    child: Text("your challenge",
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyText1.color)))),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemBuilder: (context, position) {
              return ChallengeRow(data: info.data.sentChallenge[0], type: -1);
            },
            itemCount: info.data.sentChallenge.length,
          ),
          Container(
            height: 40,
            child: Card(
                color: Theme.of(context).primaryColor,
                shape: PixelBorder.solid(
                  color: Theme.of(context).backgroundColor,
                  pixelSize: 1,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                    child: Text("recieved challenges",
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyText1.color)))),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemBuilder: (context, position) {
              return ChallengeRow(
                  data: info.data.recChallenge[position], type: 10);
            },
            itemCount: info.data.recChallenge.length,
          )
        ],
      ),
      onRefresh: () {
        return info.battleRefresh();
      },
    );
  }
}

class ChallengeRow extends StatelessWidget {
  final Challenge data;
  final int type;

  ChallengeRow({@required this.data, @required this.type});

  Widget trailing(context) {
    return Icon(Icons.keyboard_arrow_right_sharp,
        size: 38, color: Theme.of(context).textTheme.bodyText1.color);
  }

  Widget isReady(monster) {
    if (monster.readyTime < DateTime.now().millisecondsSinceEpoch / 1000) {
      return Text(' is ready', style: TextStyle(color: Colors.greenAccent));
    }
    return Text(' is not ready', style: TextStyle(color: Colors.red));
  }

  @override
  build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 60,
          width: 60,
          child: Stack(
            children: [
              Container(width: 10, height: 10),
              Hero(
                  tag: data.monster.id.toString() + type.toString(),
                  child: MonsterPicSmall(data: data.monster)),
            ],
          ),
        ),
        Expanded(
          child: Container(
            height: 60,
            child: Hero(
              tag: data.monster.id.toString() + type.toString() + "card",
              child: Card(
                color: Theme.of(context).primaryColor,
                shape: PixelBorder.solid(
                  color: Theme.of(context).backgroundColor,
                  pixelSize: 1,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Container(
                  transform: Matrix4.translationValues(0, -4, 0),
                  child: ListTile(
                    onTap: () {
                      //print("tapped " + data.seller);
                      Navigator.of(context).push(PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            Material(
                                type: MaterialType.transparency,
                                child:
                                    ChallengeDetails(data: data, type: type)),
                      ));
                    },
                    dense: true,
                    title: Text(
                      data.address.toString(),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText1.color,
                        fontSize: 11,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Text(
                          data.monster.name,
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText1.color),
                        ),
                        isReady(data.monster),
                      ],
                    ),
                    trailing: Transform(
                      transform: Matrix4.translationValues(10, -3, 0),
                      child: trailing(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
