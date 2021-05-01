part of page_classes;

class LabContent extends ConsumerWidget {
  @override
  build(BuildContext context, ScopedReader watch) {
    final info = watch(myEthDataProvider);
    final size = MediaQuery.of(context).size;
    final double itemWidth = size.width / 2;
    final double itemHeight = size.height / 3.1;
    return RefreshIndicator(
      child: ListView(
        children: [
          Container(
            height: 50,
            child: Center(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).backgroundColor),
                      onPressed: () {
                        info.openSelector(context, 6);
                        print("fusion");
                      },
                      child: Text("fusion",
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText1.color)),
                    ),
                    RaisedButton(
                      color: Theme.of(context).backgroundColor,
                      onPressed: () {
                        info.openSelector(context, 7);
                        print("enhance");
                      },
                      child: Text("enhance",
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText1.color)),
                    ),
                  ]),
            ),
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
                    child: Text("available extracts",
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyText1.color)))),
          ),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 0.82),
            physics: ClampingScrollPhysics(),
            itemBuilder: (context, position) {
              return MonsterFlipCard(
                  monster: info.data.myMonsterExtracts[position],
                  img: info.data.myMonsterExtracts[position].img);
            },
            itemCount: info.data.myMonsterExtracts.length,
          ),
        ],
      ),
      onRefresh: () {
        return info.labRefresh();
      },
    );
  }
}

class IncubatorContent extends ConsumerWidget {
  format(Duration d) => d.toString().split('.').first.padLeft(8, "0");

  Widget time(data, position, context) {
    String sign = "-";
    double now = DateTime.now().millisecondsSinceEpoch.toDouble() / 1000;
    double readyTime = data.incubating[position].readyTime;
    double time = readyTime - now;
    if (time < 0) {
      return Text("ready", style: TextStyle(fontSize: 12));
    }
    final dur = Duration(seconds: time.toInt());

    return Text(sign + format(dur) + "s",
        style: TextStyle(
            fontSize: 10, color: Theme.of(context).textTheme.bodyText1.color));
  }

  @override
  build(BuildContext context, ScopedReader watch) {
    final info = watch(myEthDataProvider);
    final size = MediaQuery.of(context).size;
    final double itemWidth = size.width / 2;
    final double itemHeight = size.height / 3.1;
    return RefreshIndicator(
      child: ListView(
        children: [
          Container(
            height: 80,
            child: Card(
                color: Theme.of(context).primaryColor,
                shape: PixelBorder.solid(
                  color: Theme.of(context).backgroundColor,
                  pixelSize: 1,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Center(
                    child: Text(
                        'The place for beasts that are incubating, recovering or otherwise unavailable for other tasks at the moment',
                        style: TextStyle(
                            fontSize: 10,
                            color:
                                Theme.of(context).textTheme.bodyText1.color)),
                  ),
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
                    child: Text("occupied",
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyText1.color)))),
          ),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, childAspectRatio: 0.9),
            physics: ClampingScrollPhysics(),
            itemBuilder: (context, position) {
              return Container(
                  height: 50,
                  width: 50,
                  child: Column(
                    children: [
                      MonsterPicSmall(data: info.data.incubating[position]),
                      time(info.data, position, context)
                    ],
                  ));
            },
            itemCount: info.data.incubating.length,
          ),
        ],
      ),
      onRefresh: () {
        return info.labRefresh();
      },
    );
  }
}
