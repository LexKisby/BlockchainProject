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

  String price() {
    double now = DateTime.now().millisecondsSinceEpoch.toDouble() / 1000;
    double passed = now - data.startTime;
    double percentage = passed / data.duration;
    double price =
        data.startPrice - (data.startPrice - data.endPrice) * percentage;

    if (price < data.endPrice) {
      return "n/a";
    }
    return price.toStringAsFixed(0);
  }

  String left() {
    double now = DateTime.now().millisecondsSinceEpoch.toDouble() / 1000;
    double passed = now - data.startTime;
    return (data.duration - passed).toStringAsFixed(0);
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

    return Text(sign + time.toStringAsFixed(0) + "s",
        style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color));
  }

  @override
  build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(children: [
        Container(
            height: 60,
            width: 60,
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
        //Padding(padding: EdgeInsets.only(left: 40)),
        Spacer(),
        time(context),

        //Stat(fontsize: 17, icon: Icons.euro_sharp, iconsize: 20, text: price())
      ]),
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
