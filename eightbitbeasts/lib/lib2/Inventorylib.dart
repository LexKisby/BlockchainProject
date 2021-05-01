part of page_classes;

class InventoryContent extends ConsumerWidget {
  int howmany(width) {
    return (width / getWidth(width)).round();
  }

  double getWidth(width) {
    double w = width / 2;
    if (w > 300) {
      return 300;
    }
    return w;
  }

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final data = watch(myEthDataProvider);
    var isNull = data.data;
    var monsterList = isNull == null ? [] : data.data.monsterList;
    var size = MediaQuery.of(context).size;
    final double itemWidth = size.width;
    final double itemHeight = size.height / 3.1;
    return RefreshIndicator(
      child: GridView.builder(
        itemBuilder: (context, position) {
          return Center(
            child: Container(
              width: getWidth(itemWidth).toDouble(),
              height: getWidth(itemWidth).toDouble() * 1.24,
              child: MonsterFlipCard(
                  monster: monsterList[position],
                  img: monsterList[position].img),
            ),
          );
        },
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 0.76, crossAxisCount: howmany(itemWidth)),
        itemCount: monsterList.length,
      ),
      onRefresh: () {
        return data.inventoryRefresh();
      },
    );
  }
}
