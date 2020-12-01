part of page_classes;

class Ruby extends ConsumerWidget {
  @override
  build(BuildContext context, ScopedReader watch) {
    final ethData = watch(myEthDataProvider);
    return Container(
        child: Row(children: [
      Icon(Icons.local_atm_sharp,
          color: Theme.of(context).textTheme.bodyText1.color, size: 22),
      SizedBox(
        height: 25,
        width: 120,
        child: Card(
            shape: PixelBorder(
                style: BorderStyle.solid,
                borderColor: Colors.black,
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
      Icon(Icons.euro_sharp,
          color: Theme.of(context).textTheme.bodyText1.color, size: 22),
      SizedBox(
        height: 25,
        width: 120,
        child: Card(
            shape: PixelBorder(
                style: BorderStyle.solid,
                borderColor: Colors.black,
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
