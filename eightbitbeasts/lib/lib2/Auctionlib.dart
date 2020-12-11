part of page_classes;

class AuctionContent extends ConsumerWidget {
  @override
  build(BuildContext context, ScopedReader watch) {
    final info = watch(myEthDataProvider);

    return ListView.builder(
      itemBuilder: (context, position) {
        return MarketRow(data: info.data.marketMonstersForAuction[position]);
      },
      itemCount: info.data.marketMonstersForAuction.length,
    );
  }
}

class MarketRow extends StatelessWidget {
  final Auction data;

  MarketRow({this.data});

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
    /*
    return Padding(
      padding: const EdgeInsets.fromLTRB(3, 1, 3, 0),
      child: Row(children: [
        Container(
            height: 70,
            width: 70,
            child: Hero(
                tag: data.monster.id,
                child: MonsterPicSmall(data: data.monster))),
        Padding(padding: EdgeInsets.only(left: 10)),
        Text(data.monster.name,
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyText1.color)),
        Padding(padding: EdgeInsets.only(left: 10)),
        Text(price(),
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyText1.color)),
        Spacer(),
        time(context),
      ]),
    ); 
    */
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            height: 60,
            width: 60,
            child: Hero(
                tag: data.monster.id,
                child: MonsterPicSmall(data: data.monster))),
        Expanded(
          child: Container(
            height: 60,
            child: Card(
              color: Theme.of(context).primaryColor,
              shape: PixelBorder(
                style: BorderStyle.solid,
                borderColor: Theme.of(context).backgroundColor,
                pixelSize: 1,
                borderRadius: BorderRadius.circular(6),
              ),
              child: ListTile(
                dense: true,
                title: Text(data.monster.name,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText1.color)),
                subtitle: Row(
                  children: [
                    price(context),
                    Spacer(),
                    time(context),
                  ],
                ),
                trailing: Transform(
                  transform: Matrix4.translationValues(10, -6, 0),
                  child: trailing(context),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DonorContent extends ConsumerWidget {
  @override
  build(BuildContext context, ScopedReader watch) {
    final info = watch(myEthDataProvider);

    return ListView.builder(
      itemBuilder: (context, position) {
        return MarketRow(data: info.data.marketMonstersForDonor[position]);
      },
      itemCount: info.data.marketMonstersForDonor.length,
    );
  }
}
