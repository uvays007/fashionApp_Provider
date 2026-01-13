import 'package:flutter/material.dart';

class Tryon extends StatefulWidget {
  const Tryon({super.key});

  @override
  State<Tryon> createState() => _TryonState();
}

class _TryonState extends State<Tryon> {
  String selectedShirt = "assets/images/Tshirt(black_china).png";
  String selectedPant = "assets/images/pngwing_pant.png";

  String selectedShirtName = "2STROKE MEN Tshirt Black";
  String selectedPantName = "Polo Men Jeans Blue";

  final List<Map<String, String>> shirts = [
    {
      "name": "2STROKE Men Tshirt Black",
      "image": "assets/images/Tshirt(black_china).png",
    },
    {
      "name": "Ortox Men Tshirt Blue",
      "image": "assets/images/Tshirt(blue).png",
    },
    {
      "name": "Gladiator Men Tshirt Green",
      "image": "assets/images/Tshirt(Green).png",
    },
  ];

  final List<Map<String, String>> pants = [
    {"name": "Polo Men Jeans Blue", "image": "assets/images/pngwing_pant.png"},
    {
      "name": "Leventer Men Jeans Black",
      "image": "assets/images/black_pant.png",
    },
    {"name": "Hasp Men Jeans Grey", "image": "assets/images/pant_blueflop.png"},
  ];

  List<Map<String, String>> filteredShirts = [];
  List<Map<String, String>> filteredPants = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredShirts = List.from(shirts);
    filteredPants = List.from(pants);
  }

  void _showItemSelector({required bool isShirt}) {
    _searchController.clear();
    setState(() {
      if (isShirt) {
        filteredShirts = List.from(shirts);
      } else {
        filteredPants = List.from(pants);
      }
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final currentSelection = isShirt ? selectedShirt : selectedPant;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 20),
                      Text(
                        isShirt ? "Select Shirt" : "Select Pant",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            suffixIcon: GestureDetector(
                              onTap: () {
                                search(isShirt, setModalState);
                              },
                              child: const Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                            ),
                            hintText: 'Search',
                            hintStyle: const TextStyle(color: Colors.grey),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                              borderSide: BorderSide(
                                color: Color(0xFFC19375),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF7F7F7),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: isShirt
                          ? filteredShirts.length
                          : filteredPants.length,
                      itemBuilder: (context, index) {
                        final item = isShirt
                            ? filteredShirts[index]
                            : filteredPants[index];
                        final isSelected = item["image"] == currentSelection;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isShirt) {
                                selectedShirt = item["image"]!;
                                selectedShirtName = item["name"]!;
                              } else {
                                selectedPant = item["image"]!;
                                selectedPantName = item["name"]!;
                              }
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFFF4EC)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFC19375)
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 90,
                                  width: 90,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Transform.translate(
                                    offset: isShirt
                                        ? const Offset(3, 15)
                                        : const Offset(3, -15),
                                    child: Transform.scale(
                                      scale: 1.5,
                                      child: Image.asset(
                                        item["image"]!,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    item["name"]!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: isSelected
                                      ? const Color(0xFFC19375)
                                      : Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void search(bool isShirt, void Function(void Function()) setModalState) {
    final query = _searchController.text.toLowerCase();

    setModalState(() {
      if (isShirt) {
        if (query.isEmpty) {
          filteredShirts = List.from(shirts);
        } else {
          final matches = shirts
              .where((item) => item["name"]!.toLowerCase().contains(query))
              .toList();
          final nonMatches = shirts
              .where((item) => !item["name"]!.toLowerCase().contains(query))
              .toList();
          filteredShirts = [...matches, ...nonMatches];
        }
      } else {
        if (query.isEmpty) {
          filteredPants = List.from(pants);
        } else {
          final matches = pants
              .where((item) => item["name"]!.toLowerCase().contains(query))
              .toList();
          final nonMatches = pants
              .where((item) => !item["name"]!.toLowerCase().contains(query))
              .toList();
          filteredPants = [...matches, ...nonMatches];
        }
      }
    });
  }

  void _showAddToCartPopup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        bool addShirt = true;
        bool addPant = true;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Add to Cart",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  GestureDetector(
                    onTap: () => setModalState(() => addShirt = !addShirt),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 10,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: addShirt
                              ? const Color(0xFFC19375)
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                        color: addShirt
                            ? const Color(0xFFFFF4EC)
                            : Colors.grey.shade100,
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Add Shirt ($selectedShirtName)",
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            addShirt
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: addShirt
                                ? const Color(0xFFC19375)
                                : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () => setModalState(() => addPant = !addPant),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 10,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: addPant
                              ? const Color(0xFFC19375)
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                        color: addPant
                            ? const Color(0xFFFFF4EC)
                            : Colors.grey.shade100,
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Add Pant ($selectedPantName)",
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            addPant
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: addPant
                                ? const Color(0xFFC19375)
                                : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC19375),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      String addedItems = '';
                      if (addShirt && addPant) {
                        addedItems = '$selectedShirtName and $selectedPantName';
                      } else if (addShirt) {
                        addedItems = selectedShirtName;
                      } else if (addPant) {
                        addedItems = selectedPantName;
                      } else {
                        addedItems = 'No items';
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added $addedItems to Cart!'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: const Text(
                      "Confirm",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Container(
                height: 325,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 240, 240, 240),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      "assets/images/Fitmax_dummy_2.png",
                      fit: BoxFit.contain,
                      height: 400,
                    ),
                    Image.asset(selectedPant, fit: BoxFit.contain, height: 400),
                    Image.asset(
                      selectedShirt,
                      fit: BoxFit.contain,
                      height: 400,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Choose Shirt',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Jomolhari',
                ),
              ),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () => _showItemSelector(isShirt: true),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    color: const Color.fromARGB(255, 240, 240, 240),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          selectedShirtName,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(Icons.add_box),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Choose Pant',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Jomolhari',
                ),
              ),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () => _showItemSelector(isShirt: false),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    color: const Color.fromARGB(255, 240, 240, 240),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          selectedPantName,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(Icons.add_box),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC19375),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  minimumSize: const Size(double.infinity, 56),
                ),
                onPressed: _showAddToCartPopup,
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
