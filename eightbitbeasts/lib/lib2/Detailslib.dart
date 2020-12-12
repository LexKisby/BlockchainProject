part of page_classes;

class AuctionDetails extends StatelessWidget {
  AuctionDetails({
    this.data,
  });

  final Auction data;

  void buy() {
    print("buy buy buy");
  }

  TextStyle style(fontsize) {
    return TextStyle(
      fontFamily: 'PressStart2P',
      fontSize: fontsize,
      color: const Color(0xfffef0d1),
    );
  }

  format(Duration d) => d.toString().split('.').first.padLeft(8, "0");

  Widget time() {
    String sign = "-";
    double now = DateTime.now().millisecondsSinceEpoch.toDouble() / 1000;
    double passed = now - data.startTime;
    double time = data.duration - passed;
    if (time < 0) {
      return Text("expired", style: style(12.toDouble()));
    }
    final dur = Duration(seconds: time.toInt());

    return Text(sign + format(dur) + "s", style: style(10.toDouble()));
  }

  Widget price() {
    double now = DateTime.now().millisecondsSinceEpoch.toDouble() / 1000;
    double passed = now - data.startTime;
    double percentage = passed / data.duration;
    double price =
        data.startPrice - (data.startPrice - data.endPrice) * percentage;

    if (price < data.endPrice) {
      return Text("-----", style: style(12.toDouble()));
    }
    return Text(price.toStringAsFixed(0), style: style(12.toDouble()));
  }

  bool expired() {
    double now = DateTime.now().millisecondsSinceEpoch.toDouble() / 1000;
    double passed = now - data.startTime;
    double percentage = passed / data.duration;
    double price =
        data.startPrice - (data.startPrice - data.endPrice) * percentage;

    if (price < data.endPrice) {
      return true;
    }
    return false;
  }

  @override
  build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Container(
          color: const Color(0xBD6706).withOpacity(0.04),
          child: Center(
            child: Stack(
              children: [
                Center(
                  child: Container(
                    height: size.height * 0.6,
                    width: size.width * 0.8,
                    child: GestureDetector(
                      onTap: () {},
                      child: Hero(
                        tag: data.monster.id.toString() + "card",
                        child: Card(
                            shape: PixelBorder(
                              style: BorderStyle.solid,
                              borderColor: Theme.of(context).backgroundColor,
                              pixelSize: 3,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    height: size.height * 0.6,
                    width: size.width * 0.75,
                    child: GestureDetector(
                      onTap: () {},
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 100,
                                width: 100,
                                transform:
                                    Matrix4.translationValues(-20, -10, 100),
                                child: Hero(
                                  tag: data.monster.id,
                                  child: MonsterPicSmall(data: data.monster),
                                ),
                              ),
                              Container(
                                child: Text(
                                  data.monster.name,
                                  style: style(30.toDouble()),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 280,
                            child: Row(
                              children: [
                                Container(
                                  height: 50,
                                  width: 100,
                                  child: Column(
                                    children: [
                                      Center(
                                          child: Text("current price",
                                              style: style(10.toDouble()))),
                                      Spacer(),
                                      Row(children: [Spacer(), price()])
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Container(
                                    height: 50,
                                    width: 110,
                                    child: Column(
                                      children: [
                                        Center(
                                            child: Text("time left",
                                                style: style(10.toDouble()))),
                                        Spacer(),
                                        Row(children: [Spacer(), time()]),
                                      ],
                                    ))
                              ],
                            ),
                          ),
                          Container(
                            width: size.width * 0.6,
                            child: Divider(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .color),
                          ),
                          Container(
                              height: 20,
                              child: Center(
                                child: Stat(
                                    fontsize: 12,
                                    iconsize: 15,
                                    text: data.monster.stats.substring(0, 3),
                                    icon: Icons.hd_sharp),
                              )),
                          GridView.count(
                            primary: false,
                            childAspectRatio: 4,
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            children: [
                              Stat(
                                  icon: Icons.open_with_sharp,
                                  iconsize: 15,
                                  text: data.monster.stats.substring(3, 6),
                                  fontsize: 12),
                              Stat(
                                  icon: Icons.format_align_justify,
                                  iconsize: 15,
                                  text: data.monster.stats.substring(6, 9),
                                  fontsize: 12),
                              Stat(
                                  icon: Icons.wallet_giftcard,
                                  iconsize: 15,
                                  text: data.monster.stats.substring(9, 12),
                                  fontsize: 12),
                              Stat(
                                  icon: Icons.pages_outlined,
                                  iconsize: 15,
                                  text: data.monster.stats.substring(12, 15),
                                  fontsize: 12),
                              Stat(
                                  icon: Icons.data_usage_sharp,
                                  iconsize: 15,
                                  text: data.monster.stats.substring(15, 18),
                                  fontsize: 12),
                              Stat(
                                  icon: Icons.amp_stories_sharp,
                                  iconsize: 15,
                                  text: data.monster.stats.substring(18, 21),
                                  fontsize: 12),
                              Stat(
                                  icon: Icons.mail_outline,
                                  iconsize: 15,
                                  text: data.monster.stats.substring(21, 24),
                                  fontsize: 12),
                              Stat(
                                  icon: Icons.radio_button_checked_outlined,
                                  iconsize: 15,
                                  text: data.monster.stats.substring(24, 27),
                                  fontsize: 12),
                            ],
                          ),
                          Container(
                            width: size.width * 0.6,
                            child: Divider(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .color),
                          ),
                          Container(
                            width: 280,
                            child: Row(
                              children: [
                                Container(
                                  height: 40,
                                  width: 100,
                                  child: Column(
                                    children: [
                                      Center(
                                          child: Text("battles won",
                                              style: style(10.toDouble()))),
                                      Spacer(),
                                      Row(children: [
                                        Spacer(),
                                        Text("##/###",
                                            style: style(12.toDouble()))
                                      ])
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  height: 40,
                                  width: 110,
                                  child: Column(
                                    children: [
                                      Center(
                                          child: Text("extractions remaining",
                                              style: style(10.toDouble()))),
                                      Spacer(),
                                      Row(children: [
                                        Spacer(),
                                        Text("##", style: style(12.toDouble()))
                                      ]),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          MarketButtons(data: data),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MarketButtons extends ConsumerWidget {
  MarketButtons({this.data});
  final data;

  TextStyle style(fontsize) {
    return TextStyle(
      fontFamily: 'PressStart2P',
      fontSize: fontsize,
      color: const Color(0xfffef0d1),
    );
  }

  void retrieve() {
//TODO
    print("retrieve monster");
  }

  void buy() {
    //TODO
    print("buying monster");
  }

  bool isMine() {
    return data.isMine;
  }

  bool expired() {
    double now = DateTime.now().millisecondsSinceEpoch.toDouble() / 1000;
    double passed = now - data.startTime;
    double percentage = passed / data.duration;
    double price =
        data.startPrice - (data.startPrice - data.endPrice) * percentage;

    if (price < data.endPrice) {
      return true;
    }
    return false;
  }

  @override
  build(BuildContext context, ScopedReader watch) {
    final info = watch(myEthDataProvider);
    return ButtonBar(
      children: [
        FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("return", style: style(15.0))),
        RaisedButton(
          disabledColor: Colors.grey,
          color: Theme.of(context).accentColor,
          onPressed: isMine()
              ? () => retrieve()
              : expired()
                  ? null
                  : () => buy(),
          child: Text(isMine() ? "retrieve" : "buy", style: style(15.0)),
        ),
      ],
    );
  }
}
