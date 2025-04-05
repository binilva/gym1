import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ProductDetailsPage.dart';
import 'cart_page.dart';
import 'dart:async';

class ShopPage extends StatefulWidget {
  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  List products = [];
  List filteredProducts = [];
  String searchQuery = "";
  RangeValues _selectedPriceRange = RangeValues(0, 1000);
  String selectedCategory = "All";
  List<String> categories = ["All"];
  bool isLoading = true;
  String errorMessage = "";
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));
      if (response.statusCode == 200) {
        setState(() {
          products = json.decode(response.body);
          filteredProducts = products;
          categories.addAll(products.map((product) => product['category'].toString()).toSet());
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Failed to load products. Please try again later.";
      });
    }
  }

  void filterProducts() {
    setState(() {
      filteredProducts = products.where((product) {
        final title = product['title'].toString().toLowerCase();
        final price = double.tryParse(product['price'].toString()) ?? 0;
        final category = product['category'].toString();

        return title.contains(searchQuery.toLowerCase()) &&
            price >= _selectedPriceRange.start &&
            price <= _selectedPriceRange.end &&
            (selectedCategory == "All" || category == selectedCategory);
      }).toList();
    });
  }

  void onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: 500), () {
      setState(() {
        searchQuery = value;
        filterProducts();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gym Shop'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CartPage()),
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
          : Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                labelText: "Search Products",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: selectedCategory == category,
                      onSelected: (isSelected) {
                        setState(() {
                          selectedCategory = isSelected ? category : "All";
                          filterProducts();
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text("Price Range: \$${_selectedPriceRange.start.toInt()} - \$${_selectedPriceRange.end.toInt()}"),
                RangeSlider(
                  values: _selectedPriceRange,
                  min: 0,
                  max: 1000,
                  divisions: 20,
                  labels: RangeLabels(
                      "\$${_selectedPriceRange.start.toInt()}",
                      "\$${_selectedPriceRange.end.toInt()}"
                  ),
                  onChanged: (values) {
                    setState(() {
                      _selectedPriceRange = values;
                      filterProducts();
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(child: Text("No products found"))
                : GridView.builder(
              padding: EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsPage(
                          product: filteredProducts[index],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Image.network(
                            filteredProducts[index]['image'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            filteredProducts[index]['title'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("\$${filteredProducts[index]['price']}",
                              style: TextStyle(fontWeight: FontWeight.bold)),
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
  }
}
