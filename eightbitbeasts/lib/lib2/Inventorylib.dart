part of page_classes;

class InventoryContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final myMonstersInfo = watch(myMonstersProvider);
    myMonstersInfo.update();
    final numOfMonsters = myMonstersInfo.info.length;
    print(numOfMonsters);
    var size = MediaQuery.of(context).size;
    final double itemWidth = size.width / 2;
    final double itemHeight = size.height / 3.1;
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: itemWidth / itemHeight,
      children: [
        MonsterFlipCard(
            monster: myMonstersInfo.info[0], img: myMonstersInfo.imgs[0]),
        MonsterFlipCard(
            monster: myMonstersInfo.info[1], img: myMonstersInfo.imgs[1]),
      ],
    );
  }
}
