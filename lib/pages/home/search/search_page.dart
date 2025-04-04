import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cart_veg/bloc/search/search_bloc.dart';
import 'package:iconsax/iconsax.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch products when the page is loaded
    context.read<SearchBloc>().add(FetchSearchProducts());
    _searchController.addListener(_onSearchQueryChanged);
  }

  void _onSearchQueryChanged() {
    // Dispatch the search query event
    final query = _searchController.text;
    context.read<SearchBloc>().add(SearchQueryChanged(query));
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchQueryChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Search Products")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // **Search Bar with AutoFocus**
              TextField(
                controller: _searchController,
                cursorColor: Colors.green.shade900,
                autofocus: true, // 👈 Auto-focus enabled
                decoration: InputDecoration(
                  hintText: "Search products...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.green.shade900),
                  ),
                  prefixIcon: const Icon(Iconsax.search_favorite4),
                  suffixIcon: Visibility(
                    visible: _searchController.text.isNotEmpty,
                    child: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // **Search Results List**
              BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SearchError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else if (state is SearchLoaded) {
                    final products = state.products;
                    if (products.isEmpty) {
                      return const Center(child: Text('No results found.'));
                    }
                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            tileColor: Colors.grey.shade50,
                            title: Text(product.name),
                            leading: Image.network(
                              product.image,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    );
                  }

                  // If no products and the search input is empty
                  return _searchController.text.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Iconsax.search_favorite4,
                                  size: 50, color: Colors.grey),
                              const SizedBox(height: 10),
                              const Text(
                                'Start typing to search for products.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : const Center(child: Text('No products available.'));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
