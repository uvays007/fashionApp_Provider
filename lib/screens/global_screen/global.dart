final List<Map<String, dynamic>> offlineproducts = [];

List<bool> isLiked = List.generate(offlineproducts.length, (index) => false);

final List<Map<String, dynamic>> notifications = [
  {
    "message": "Get 25% off on all men’s clothing this weekend only!",
    "time": "5h ago",
  },
  {
    "message": "Items from your wishlist are now on sale. Don’t miss out!",
    "time": "1 day ago",
  },
];
String? nameid;
