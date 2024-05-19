import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'search.dart';

class SelectCategory extends StatefulWidget {
  final List<dynamic> services;
  const SelectCategory({Key? key, required this.services}) : super(key: key);

  @override
  State<SelectCategory> createState() => _SelectCategoryState();
}

class _SelectCategoryState extends State<SelectCategory> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> filteredServices = [];
  List<int> selectedCategories = [];

  @override
  void initState() {
    super.initState();
    filteredServices = widget.services;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          List<int> selectedCategoriesData = selectedCategories.map((index) => int.parse(filteredServices[index]['id'])).toList();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SearchPage(services_id: selectedCategoriesData)),
          );
        },
        child: Icon(Icons.arrow_forward),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.grey,
        elevation: 2,
        title: Text(
          "Select needed category",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              controller: searchController,
              onChanged: filterServices,
              decoration: InputDecoration(
                labelText: 'Search by service name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of items in each row
                  crossAxisSpacing: 10, // Spacing between items horizontally
                  mainAxisSpacing: 10, // Spacing between items vertically
                  childAspectRatio: 0.75, // Aspect ratio of each item
                ),
                itemCount: filteredServices.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selectedCategories.contains(index)) {
                          selectedCategories.remove(index);
                        } else {
                          selectedCategories.add(index);
                        }
                      });
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: selectedCategories.contains(index) ? 8 : 5,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: "https://switch.unotelecom.com/fixpert/assets/services_image/${filteredServices[index]['image_uri']}",
                                  placeholder: (context, url) => LoadingAnimationWidget.prograssiveDots(
                                    color: Colors.blueAccent,
                                    size: 50,
                                  ), // Loading indicator
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.error,
                                    size: 50,
                                  ), // Error widget if image fails to load
                                  width: double.infinity,
                                  height: screenHeight * 0.2,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  filteredServices[index]['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          if (selectedCategories.contains(index)) // Display check icon if selected
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green.withOpacity(0.8), // Adjust opacity as needed
                              ),
                              padding: EdgeInsets.all(8), // Adjust padding as needed
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void filterServices(String query) {
    // If the query is empty, display all services
    if (query.isEmpty) {
      setState(() {
        filteredServices = widget.services;
      });
      return;
    }

    // Filter services based on the query
    List<dynamic> filteredList = widget.services.where((service) {
      return service['name'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredServices = filteredList;
    });
  }
}
