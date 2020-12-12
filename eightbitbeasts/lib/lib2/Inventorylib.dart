part of page_classes;

class InventoryContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final data = watch(myEthDataProvider);
    var size = MediaQuery.of(context).size;
    final double itemWidth = size.width / 2;
    final double itemHeight = size.height / 3.1;
    /*return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: itemWidth / itemHeight,
      children: [
        MonsterFlipCard(
            monster: myMonstersInfo.info[0], img: myMonstersInfo.imgs[0]),
        MonsterFlipCard(
            monster: myMonstersInfo.info[1], img: myMonstersInfo.imgs[1]),
        MonsterFlipCard(
            monster: myMonstersInfo.info[2], img: myMonstersInfo.imgs[2]),
        MonsterFlipCard(
            monster: myMonstersInfo.info[3], img: myMonstersInfo.imgs[2]),
        MonsterFlipCard(
            monster: myMonstersInfo.info[4], img: myMonstersInfo.imgs[2]),
        MonsterFlipCard(
            monster: myMonstersInfo.info[5], img: myMonstersInfo.imgs[2]),
        MonsterFlipCard(
            monster: myMonstersInfo.info[6], img: myMonstersInfo.imgs[2]),
        MonsterFlipCard(
            monster: myMonstersInfo.info[7], img: myMonstersInfo.imgs[2]),
        MonsterFlipCard(
            monster: myMonstersInfo.info[8], img: myMonstersInfo.imgs[2]),
        MonsterFlipCard(
            monster: myMonstersInfo.info[9], img: myMonstersInfo.imgs[2])
      ],
    );*/
    return GridView.builder(
      itemBuilder: (context, position) {
        return MonsterFlipCard(
            monster: data.data.monsterList[position],
            img: data.data.monsterImageList[position]);
      },
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: itemWidth / itemHeight, crossAxisCount: 2),
      itemCount: data.data.monsterList.length,
    );
  }
}
