part of page_classes;

class Ruby extends ConsumerWidget {
  @override
  build(BuildContext context, ScopedReader watch) {
    final ethData = watch(myEthDataProvider);
    return Container(
        child: Row(children: [
      Container(
        height: 20,
        width: 20,
        child: Image.asset("lib/assets/ruby.png"),
      ),
      SizedBox(
        height: 25,
        width: 120,
        child: Card(
            shape: PixelBorder.solid(
                color: Colors.black,
                pixelSize: 1,
                borderRadius: BorderRadius.circular(4)),
            color: Theme.of(context).backgroundColor,
            child: Row(children: [
              Spacer(),
              Text(
                ethData.data.rubies.toString(),
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodyText1.color),
              )
            ])),
      )
    ]));
  }
}

class Essence extends ConsumerWidget {
  @override
  build(BuildContext context, ScopedReader watch) {
    final ethData = watch(myEthDataProvider);
    return Container(
        child: Row(children: [
      Container(
        height: 20,
        width: 20,
        child: Image.asset("lib/assets/essence.png"),
      ),
      SizedBox(
        height: 25,
        width: 120,
        child: Card(
            shape: PixelBorder.solid(
                color: Colors.black,
                pixelSize: 1,
                borderRadius: BorderRadius.circular(4)),
            color: Theme.of(context).backgroundColor,
            child: Row(children: [
              Spacer(),
              Text(
                ethData.data.essence.toString(),
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodyText1.color),
              )
            ])),
      )
    ]));
  }
}

class RubyIcon extends StatelessWidget {
  RubyIcon({
    @required this.height,
  });

  final double height;
  @override
  build(BuildContext context) {
    return Container(
        height: height,
        width: height,
        child: Image.asset("lib/assets/ruby.png"));
  }
}

class EssenceIcon extends StatelessWidget {
  EssenceIcon({@required this.height});
  final double height;

  build(BuildContext context) {
    return Container(
      height: height,
      width: height,
      child: Image.asset("lib/assets/essence.png"),
    );
  }
}
