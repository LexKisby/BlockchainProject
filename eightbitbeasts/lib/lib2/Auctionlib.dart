part of page_classes;

class AuctionContent extends ConsumerWidget {
  @override
  build(BuildContext context, ScopedReader watch) {
    final info = watch(myEthDataProvider);

    return RefreshIndicator(
      child: ListView.builder(
        itemBuilder: (context, position) {
          return MarketRow(data: info.data.marketMonstersForAuction[position]);
        },
        itemCount: info.data.marketMonstersForAuction.length,
      ),
      onRefresh: () {
        return info.marketRefresh();
      },
    );
  }
}

class DonorContent extends ConsumerWidget {
  @override
  build(BuildContext context, ScopedReader watch) {
    final info = watch(myEthDataProvider);

    return RefreshIndicator(
      child: ListView.builder(
        itemBuilder: (context, position) {
          return MarketRow(data: info.data.marketMonstersForDonor[position]);
        },
        itemCount: info.data.marketMonstersForDonor.length,
      ),
      onRefresh: () {
        return info.marketRefresh();
      },
    );
  }
}

class MyMarketContent extends ConsumerWidget {
  @override
  build(BuildContext context, ScopedReader watch) {
    final info = watch(myEthDataProvider);

    return RefreshIndicator(
      child: ListView(
        children: [
          Container(
            height: 50,
            child: Center(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RaisedButton(
                      color: Theme.of(context).backgroundColor,
                      onPressed: () {
                        //TODO
                        print("add auction");
                      },
                      child: Text("add auction",
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText1.color)),
                    ),
                    RaisedButton(
                      color: Theme.of(context).backgroundColor,
                      onPressed: () {
                        //TODO
                        print("add extract");
                      },
                      child: Text("add extract",
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText1.color)),
                    )
                  ]),
            ),
          ),
          Container(
            height: 40,
            child: Card(
                color: Theme.of(context).primaryColor,
                shape: PixelBorder(
                  style: BorderStyle.solid,
                  borderColor: Theme.of(context).backgroundColor,
                  pixelSize: 1,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                    child: Text("for auction",
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyText1.color)))),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemBuilder: (context, position) {
              return MarketRow(
                  data: info.data.myMarketMonstersForAuction[position]);
            },
            itemCount: info.data.myMarketMonstersForAuction.length,
          ),
          Container(
            height: 40,
            child: Card(
                color: Theme.of(context).primaryColor,
                shape: PixelBorder(
                  style: BorderStyle.solid,
                  borderColor: Theme.of(context).backgroundColor,
                  pixelSize: 1,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                    child: Text("for extraction",
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyText1.color)))),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemBuilder: (context, position) {
              return MarketRow(
                  data: info.data.myMarketMonstersForDonor[position]);
            },
            itemCount: info.data.myMarketMonstersForDonor.length,
          )
        ],
      ),
      onRefresh: () {
        return info.marketRefresh();
      },
    );
  }
}

class MarketRow extends StatelessWidget {
  final Auction data;

  MarketRow({@required this.data});

  format(Duration d) => d.toString().split('.').first.padLeft(8, "0");

  Widget price(context) {
    double now = DateTime.now().millisecondsSinceEpoch.toDouble() / 1000;
    double passed = now - data.startTime;
    double percentage = passed / data.duration;
    double price =
        data.startPrice - (data.startPrice - data.endPrice) * percentage;

    if (price < data.endPrice) {
      return Text("-----",
          style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color));
    }
    return Text(price.toStringAsFixed(0),
        style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color));
  }

  Widget time(context) {
    String sign = "-";
    double now = DateTime.now().millisecondsSinceEpoch.toDouble() / 1000;
    double passed = now - data.startTime;
    double time = data.duration - passed;
    if (time < 0) {
      return Text("expired",
          style: TextStyle(color: Theme.of(context).accentColor));
    }
    final dur = Duration(seconds: time.toInt());

    return Text(
      sign + format(dur) + "s",
      style: TextStyle(
          color: Theme.of(context).textTheme.bodyText1.color, fontSize: 9),
    );
  }

  Widget trailing(context) {
    return Icon(Icons.keyboard_arrow_right_sharp,
        size: 38, color: Theme.of(context).textTheme.bodyText1.color);
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
                  tag: data.monster.id,
                  child: MonsterPicSmall(data: data.monster)),
            ],
          ),
        ),
        Expanded(
          child: Container(
            height: 60,
            child: Hero(
              tag: data.monster.id.toString() + "card",
              child: Card(
                color: Theme.of(context).primaryColor,
                shape: PixelBorder(
                  style: BorderStyle.solid,
                  borderColor: Theme.of(context).backgroundColor,
                  pixelSize: 1,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Container(
                  transform: Matrix4.translationValues(0, -4, 0),
                  child: ListTile(
                    onTap: () {
                      print("tapped " + data.seller);
                      Navigator.of(context).push(PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            Material(
                                type: MaterialType.transparency,
                                child: AuctionDetails(data: data)),
                      ));
                    },
                    dense: true,
                    title: Text(
                      data.monster.name,
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1.color),
                    ),
                    subtitle: Row(
                      children: [
                        price(context),
                        Spacer(),
                        time(context),
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
