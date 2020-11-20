part of page_classes;

class InventoryContent extends StatefulWidget {
  @override
  State createState() => _InventoryContentState();
}

class _InventoryContentState extends State<InventoryContent> {
  var arr = [1, 2, 3, 4, 5, 6, 7, 8];

  void _getInventory() {
    /* Function to get the inventory of the user, then assemble into a list of custom classes called MonsterflipCard */
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemWidth = size.width / 2;
    final double itemHeight = size.height / 3.1;
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: itemWidth / itemHeight,
      children: [
        MonsterFlipCard(
            name: "1234567890",
            dna: "poo",
            img: Image.asset("lib/assets/man.png"),
            n: 1,
            stats: "he sucks"),
        MonsterFlipCard(
            name: "AVOCADO",
            dna: "poo",
            img: Image.asset("lib/assets/fox.png"),
            n: 1,
            stats: "he stings"),
        MonsterFlipCard(
            name: "COW",
            dna: "poo",
            img: Image.asset("lib/assets/cat.png"),
            n: 1,
            stats: "he flies"),
        MonsterFlipCard(
            name: "VELINA",
            dna: "poo",
            img: Image.asset("lib/assets/bee.png"),
            n: 1,
            stats: "he sucks"),
        MonsterFlipCard(
            name: "STINGER",
            dna: "poo",
            img: Image.asset("lib/assets/fox.png"),
            n: 1,
            stats: "he sucks"),
        MonsterFlipCard(
            name: "FRANKIE",
            dna: "poo",
            img: Image.asset("lib/assets/cat.png"),
            n: 1,
            stats: "he sucks")
      ],
    );
  }
}
