part of page_classes;

class InventoryContent extends StatefulWidget {
  @override
  State createState() => _InventoryContentState();
}

class _InventoryContentState extends State<InventoryContent> {
  var arr = [1,2,3,4,5,6,7,8];
 

  void _getInventory() {
    /* Function to get the inventory of the user, then assemble into a list of custom classes called MonsterCard */
  }

  @override
  Widget build(BuildContext context) {
     var size = MediaQuery.of(context).size;
     final double itemWidth = size.width/2;
     final double itemHeight = size.height/2;
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: itemWidth/itemHeight,
      children: [
        MonsterCard(),
        MonsterCard(),
        MonsterCard(),
        MonsterCard(),
        MonsterCard(),
        MonsterCard()
      ],
      );
    
  }
}