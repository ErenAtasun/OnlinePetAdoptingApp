import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/pet.dart';
import '../../../core/providers/pet_provider.dart';
import '../../pets/presentation/pet_card.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();
  PetSpecies? _selectedSpecies;
  PetSize? _selectedSize;
  String? _selectedCity;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final hasFilters = _selectedSpecies != null ||
        _selectedSize != null ||
        (_selectedCity?.isNotEmpty ?? false);

    if (!hasFilters) {
      ref.read(petSearchProvider.notifier).clear();
      if (mounted) {
        setState(() {
          _hasSearched = false;
        });
      }
      return;
    }

    try {
      await ref.read(petSearchProvider.notifier).search(
            species: _selectedSpecies?.name,
            city: _selectedCity,
            size: _selectedSize,
          );
      if (mounted) {
        setState(() {
          _hasSearched = true;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasSearched = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Arama sirasinda bir sorun olustu: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(petSearchProvider);
    final allPetsAsync = ref.watch(petsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Pets'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search by city',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _selectedCity = null;
                              });
                              _performSearch();
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value.isEmpty ? null : value;
                    });
                    _performSearch();
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<PetSpecies>(
                        value: _selectedSpecies,
                        decoration: const InputDecoration(
                          labelText: 'Species',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        items: PetSpecies.values.map((species) {
                          return DropdownMenuItem(
                            value: species,
                            child: Text(species.name.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSpecies = value;
                          });
                          _performSearch();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<PetSize>(
                        value: _selectedSize,
                        decoration: const InputDecoration(
                          labelText: 'Size',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        items: PetSize.values.map((size) {
                          return DropdownMenuItem(
                            value: size,
                            child: Text(size.name.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSize = value;
                          });
                          _performSearch();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedSpecies = null;
                            _selectedSize = null;
                            _selectedCity = null;
                            _searchController.clear();
                            _hasSearched = false;
                          });
                          ref.read(petSearchProvider.notifier).clear();
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear Filters'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: !_hasSearched
                ? allPetsAsync.when(
                    data: (pets) {
                      if (pets.isEmpty) {
                        return const Center(
                          child: Text('No pets available'),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: pets.length,
                        itemBuilder: (context, index) {
                          final pet = pets[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: PetCard(
                              pet: pet,
                              onTap: () => context.push('/pets/${pet.id}'),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stack) => Center(
                      child: Text('Error: $error'),
                    ),
                  )
                : searchResults.isEmpty
                    ? const Center(
                        child: Text('Arama kriterlerine uygun sonuc bulunamadi'),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final pet = searchResults[index];
                          return PetCard(
                            pet: pet,
                            onTap: () => context.push('/pets/${pet.id}'),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

