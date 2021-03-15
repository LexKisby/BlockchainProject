part of page_classes;

class InventoryContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final data = watch(myEthDataProvider);
    var isNull = data.data;
    var monsterList = isNull == null ? [] : data.data.monsterList;
    var size = MediaQuery.of(context).size;
    final double itemWidth = size.width / 2;
    final double itemHeight = size.height / 3.1;
    return RefreshIndicator(
      child: GridView.builder(
        itemBuilder: (context, position) {
          return MonsterFlipCard(
              monster: monsterList[position], img: monsterList[position].img);
        },
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: itemWidth / itemHeight, crossAxisCount: 2),
        itemCount: monsterList.length,
      ),
      onRefresh: () {
        return data.inventoryRefresh();
      },
    );
  }
}
