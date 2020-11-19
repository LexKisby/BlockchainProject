part of page_classes;

class InventoryContent extends StatefulWidget {
  @override
  State createState() => _InventoryContentState();
}

class _InventoryContentState extends State<InventoryContent> {
  var arr = [1, 2, 3, 4, 5, 6, 7, 8];

  void _getInventory() {
    /* Function to get the inventory of the user, then assemble into a list of custom classes called MonsterCard */
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemWidth = size.width / 2;
    final double itemHeight = size.height / 2;
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: itemWidth / itemHeight,
      children: [
        MonsterCard(
            name: "Potato Monster",
            dna: "poo",
            img: Image.asset("lib/assets/man.png"),
            n: 1,
            stats: "he sucks"),
        MonsterCard(
            name: "AVOCADO",
            dna: "poo",
            img: Image.asset("lib/assets/bee.png"),
            n: 1,
            stats: "he stings"),
        MonsterCard(
            name: "cow monster",
            dna: "poo",
            img: Image.asset("lib/assets/flutter.png"),
            n: 1,
            stats: "he flies"),
        MonsterCard(
            name: "potato monster",
            dna: "poo",
            img: Image.asset("lib/assets/man.png"),
            n: 1,
            stats: "he sucks"),
        MonsterCard(
            name: "potato monster",
            dna: "poo",
            img: Image.asset("lib/assets/man.png"),
            n: 1,
            stats: "he sucks"),
        MonsterCard(
            name: "potato monster",
            dna: "poo",
            img: Image.asset("lib/assets/man.png"),
            n: 1,
            stats: "he sucks")
      ],
    );
  }
}
