part of page_classes;

class LeaderBoards extends ConsumerWidget {
  build(BuildContext context, ScopedReader watch) {
    return Center(child: Text("to be server based"));
  }
}

class DungeonBox extends ConsumerWidget {
  DungeonBox({this.pos});
  final pos;

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
                shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(7))),
                color: Theme.of(context).primaryColor,
                child: Row(
                  children: [
                    Container(width: 10),
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
    return Center(child: Text("Coming soon"));
  }
}
