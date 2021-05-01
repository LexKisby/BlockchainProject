part of page_classes;

class AuctionDetails extends StatelessWidget {
  AuctionDetails({@required this.data, @required this.type});

  final Auction data;
  final int type;

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
                            shape: PixelBorder.solid(
                              color: Theme.of(context).backgroundColor,
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
                    width: size.width * 0.77,
                    child: GestureDetector(
                      onTap: () {},
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                height: size.height / 4.5,
                                width: size.height / 4.5,
                                transform: Matrix4.translationValues(
                                    -size.width / 20, -size.height / 20, 100),
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
                            width: size.width * 0.6,
                            child: Row(
                              children: [
                                Container(
                                  height: 50,
                                  width: size.width * 0.25,
                                  child: Column(
                                    children: [
                                      Center(
                                          child: Text("current price",
                                              style: style(10.toDouble()))),
                                      Spacer(),
                                      Row(children: [
                                        EssenceIcon(height: 24.0),
                                        Spacer(),
                                        price()
                                      ])
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Container(
                                    height: 50,
                                    width: size.width * 0.25,
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
                                    icon: Icons.favorite),
                              )),
                          GridView.count(
                            primary: false,
                            childAspectRatio: size.width / 100,
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            children: [
                              Stat(
                                  icon: Icons.flash_on,
                                  iconsize: 15,
                                  text: data.monster.stats.substring(3, 6),
                                  fontsize: 12),
                              Stat(
                                  icon: Icons.open_with_sharp,
                                  iconsize: 15,
                                  text: data.monster.stats.substring(6, 9),
                                  fontsize: 12),
                              Stat(
                                  icon: Icons.label_important,
                                  iconsize: 15,
                                  text: data.monster.stats.substring(9, 12),
                                  fontsize: 12),
                              Stat(
                                  icon: Icons.label_important_outline,
                                  iconsize: 15,
                                  text: data.monster.stats.substring(12, 15),
                                  fontsize: 12),
                              Stat(
                                  icon: Icons.looks_sharp,
                                  iconsize: 15,
                                  text: data.monster.stats.substring(15, 18),
                                  fontsize: 12),
                              Stat(
                                  icon: Icons.radio_button_checked_outlined,
                                  iconsize: 15,
                                  text: data.monster.stats.substring(18, 21),
                                  fontsize: 12),
                              Stat(
                                  icon: Icons.switch_right,
                                  iconsize: 15,
                                  text: data.monster.stats.substring(21, 24),
                                  fontsize: 12),
                              Stat(
                                  icon: Icons.emoji_objects,
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
                                        Text(
                                            data.monster.wins
                                                    .round()
                                                    .toString() +
                                                '/' +
                                                (data.monster.wins +
                                                        data.monster.losses)
                                                    .round()
                                                    .toString(),
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
                                        Text(data.monster.remaining.toString(),
                                            style: style(12.toDouble()))
                                      ]),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Spacer(),
                          MarketButtons(data: data, type: type),
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
  MarketButtons({this.data, this.type});
  final data;
  final type;

  TextStyle style(fontsize) {
    return TextStyle(
      fontFamily: 'PressStart2P',
      fontSize: fontsize,
      color: const Color(0xfffef0d1),
    );
  }

  Future<String> retrieve(context, info) async {
    info.selectedMonsters = [];
    info.selectedAuctions = [];
    //print('is this ok');
    //print(data);
    info.selectedMonsters.add(data.monster);
    info.selectedAuctions.add(data);
    //print('is the problem here');
    await info.getEtherBalance();
    return await info.prepTransaction(context, type);
    //print("retrieve monster");
  }

  Future<String> buy(context, info) async {
    info.selectedMonsters = [];

    info.selectedMonsters.add(data.monster);
    info.selectedAuctions.add(data);
    await info.getEtherBalance();
    return await info.prepTransaction(context, type + 2);
    //print("buying monster");
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
          onPressed: () async {
            String res;
            if (isMine()) {
              res = await retrieve(context, info);
            } else {
              res = await buy(context, info);
            }
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(res)));
            Navigator.pop(context);
          },
          child: Text(isMine() ? "retrieve" : "buy", style: style(15.0)),
        ),
      ],
    );
  }
}

class ChallengeDetails extends StatelessWidget {
  ChallengeDetails({@required this.data, @required this.type});

  final Challenge data;
  final int type;

  TextStyle style(fontsize) {
    return TextStyle(
      fontFamily: 'PressStart2P',
      fontSize: fontsize,
      color: const Color(0xfffef0d1),
    );
  }

  Widget isReady(monster) {
    if (monster.readyTime < DateTime.now().millisecondsSinceEpoch / 1000) {
      return Text('ready',
          style: TextStyle(color: Colors.greenAccent, fontSize: 20));
    }
    return Text('not ready', style: TextStyle(color: Colors.red, fontSize: 20));
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
                        tag: data.monster.id.toString() +
                            type.toString() +
                            'card',
                        child: Card(
                            shape: PixelBorder.solid(
                              color: Theme.of(context).backgroundColor,
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
                                height: size.width / 3.7,
                                width: size.width / 3.7,
                                transform: Matrix4.translationValues(
                                    -size.width / 12, -size.height / 25, 100),
                                child: Hero(
                                  tag: data.monster.id.toString() +
                                      type.toString(),
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
                                Spacer(),
                                Container(
                                    height: size.height / 20,
                                    child: isReady(data.monster)),
                                Spacer()
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
                                    icon: Icons.favorite),
                              )),
                          GridView.count(
                            primary: false,
                            childAspectRatio: size.width / 100,
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            children: [
                              Stat(
                                  icon: Icons.flash_on,
                                  iconsize: 15,
                                  text: data.monster.stats.substring(3, 6),
                                  fontsize: 12),
                              Stat(
                                  icon: Icons.open_with_sharp,
                                  iconsize: 15,
                                  text: data.monster.stats.substring(6, 9),
                                  fontsize: 12),
                              Stat(
                                  icon: Icons.label_important,
                                  iconsize: 15,
                                  text: data.monster.stats.substring(9, 12),
                                  fontsize: 12),
                              Stat(
                                  icon: Icons.label_important_outline,
                                  iconsize: 15,
                                  text: data.monster.stats.substring(12, 15),
                                  fontsize: 12),
                              Stat(
                                  icon: Icons.looks_sharp,
                                  iconsize: 15,
                                  text: data.monster.stats.substring(15, 18),
                                  fontsize: 12),
                              Stat(
                                  icon: Icons.radio_button_checked_outlined,
                                  iconsize: 15,
                                  text: data.monster.stats.substring(18, 21),
                                  fontsize: 12),
                              Stat(
                                  icon: Icons.switch_right,
                                  iconsize: 15,
                                  text: data.monster.stats.substring(21, 24),
                                  fontsize: 12),
                              Stat(
                                  icon: Icons.emoji_objects,
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
                                        Text(
                                            data.monster.wins
                                                    .round()
                                                    .toString() +
                                                '/' +
                                                (data.monster.wins +
                                                        data.monster.losses)
                                                    .round()
                                                    .toString(),
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
                                        Text(data.monster.remaining.toString(),
                                            style: style(12.toDouble()))
                                      ]),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Spacer(),
                          ChallengeButtons(data: data, type: type),
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

class ChallengeButtons extends ConsumerWidget {
  ChallengeButtons({this.data, this.type});
  final data;
  final type;

  TextStyle style(fontsize) {
    return TextStyle(
      fontFamily: 'PressStart2P',
      fontSize: fontsize,
      color: const Color(0xfffef0d1),
    );
  }

  Widget button(type, info, context) {
    if (type == -1) {
      return Container();
    }
    return RaisedButton(
      disabledColor: Colors.grey,
      color: Theme.of(context).accentColor,
      onPressed: () async {
        info.arguments = [data.index];
        info.openSelector(context, 10);
      },
      child: Text('accept', style: style(15.0)),
    );
  }

  Future<String> retrieve(context, info) async {
    info.selectedMonsters = [];
    info.selectedAuctions = [];
    //print('is this ok');
    //print(data);
    info.selectedMonsters.add(data.monster);
    info.selectedAuctions.add(data);
    //print('is the problem here');
    await info.getEtherBalance();
    return await info.prepTransaction(context, type);
    //print("retrieve monster");
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
        button(type, info, context),
      ],
    );
  }
}
