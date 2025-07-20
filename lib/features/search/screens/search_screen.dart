import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../provider/search_provider.dart';
import '../../../shared/widgets/filter_bottom_sheet.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/widgets/pg_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  Timer? _searchDebouncer;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
    _setupScrollListener();
  }

  void _initializeScreen() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchProvider>().initialize();
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (!mounted) return;

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        // Load more results when user scrolls to the bottom
        context.read<SearchProvider>().loadMoreResults();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    _searchDebouncer?.cancel();
    super.dispose();
  }

  void _handleSearch(String query) {
    setState(() {
      _showSuggestions = query.isNotEmpty;
    });

    _searchDebouncer?.cancel();
    _searchDebouncer = Timer(const Duration(milliseconds: 500), () {
      if (mounted && query.isNotEmpty) {
        context.read<SearchProvider>().searchPGs(query);
        setState(() {
          _showSuggestions = false;
        });
      }
    });
  }

  void _selectSuggestion(String suggestion) {
    _searchController.text = suggestion;
    setState(() {
      _showSuggestions = false;
    });
    context.read<SearchProvider>().searchPGs(suggestion);
  }

  void _showFilterSheet() {
    final searchProvider = context.read<SearchProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => FilterBottomSheet(
            initialFilters: searchProvider.activeFilters,
            onFiltersApplied: (filters) {
              searchProvider.applyFilters(filters);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'Find Your PG',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.deepCharcoal,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search bar section
          _buildSearchBar(),

          // Recent searches chips
          _buildRecentSearchesChips(),

          // Filter section
          _buildFilterSection(),

          // Suggestions or results
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, provider, child) {
                if (_showSuggestions) {
                  return _buildSearchSuggestions(provider);
                }

                if (provider.searchQuery.isEmpty) {
                  return _buildEmptyState();
                }

                if (provider.isLoading && provider.searchResults.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.hasError) {
                  return _buildErrorState(provider.errorMessage);
                }

                if (provider.searchResults.isEmpty) {
                  return _buildNoResultsState();
                }

                return _buildSearchResults(provider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.gray100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: 'Search by location, PG name, amenities...',
            hintStyle: TextStyle(color: AppTheme.gray500, fontSize: 14),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.emeraldGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.search_rounded,
                color: AppTheme.emeraldGreen,
                size: 16,
              ),
            ),
            suffixIcon:
                _searchController.text.isNotEmpty
                    ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: AppTheme.gray500,
                        size: 16,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _showSuggestions = false;
                        });
                        context.read<SearchProvider>().clearSearch();
                      },
                    )
                    : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: _handleSearch,
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              context.read<SearchProvider>().searchPGs(value);
              setState(() {
                _showSuggestions = false;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildRecentSearchesChips() {
    return Consumer<SearchProvider>(
      builder: (context, provider, child) {
        if (provider.recentSearches.isEmpty ||
            _searchController.text.isNotEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Searches',
                    style: TextStyle(
                      color: AppTheme.gray700,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (provider.recentSearches.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        provider.clearSearchHistory();
                      },
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          color: AppTheme.emeraldGreen,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    provider.recentSearches.take(5).map((search) {
                      return GestureDetector(
                        onTap: () => _selectSuggestion(search),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.emeraldGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.emeraldGreen.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.history,
                                color: AppTheme.emeraldGreen,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                search,
                                style: TextStyle(
                                  color: AppTheme.emeraldGreen,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterSection() {
    return Consumer<SearchProvider>(
      builder: (context, provider, child) {
        if (provider.searchQuery.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  provider.hasFiltersApplied
                      ? provider.getFilterSummary()
                      : 'No filters applied',
                  style: TextStyle(color: AppTheme.gray700, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                onTap: _showFilterSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        provider.hasFiltersApplied
                            ? AppTheme.emeraldGreen
                            : AppTheme.gray100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.filter_list,
                        size: 16,
                        color:
                            provider.hasFiltersApplied
                                ? Colors.white
                                : AppTheme.gray700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        provider.hasFiltersApplied
                            ? '${provider.activeFilterCount} Filters'
                            : 'Filter',
                        style: TextStyle(
                          color:
                              provider.hasFiltersApplied
                                  ? Colors.white
                                  : AppTheme.gray700,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchSuggestions(SearchProvider provider) {
    final suggestions = provider.getSearchSuggestions(_searchController.text);

    return Container(
      color: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: suggestions.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return ListTile(
            leading: const Icon(Icons.search, color: AppTheme.gray600),
            title: Text(suggestion),
            contentPadding: EdgeInsets.zero,
            onTap: () => _selectSuggestion(suggestion),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.emeraldGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_rounded,
                size: 48,
                color: AppTheme.emeraldGreen,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Find Your Perfect PG',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.deepCharcoal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Search by location, PG name, or amenities to discover your ideal accommodation',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.gray600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildQuickSearchSuggestions(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSearchSuggestions() {
    final suggestions = [
      'PG in Koramangala',
      'PG near Metro Station',
      'PG with AC',
      'Girls PG',
      'Under ₹10,000',
      'PG with meals',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Searches',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.deepCharcoal,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children:
              suggestions.map((suggestion) {
                return GestureDetector(
                  onTap: () => _selectSuggestion(suggestion),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.emeraldGreen.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      suggestion,
                      style: TextStyle(
                        color: AppTheme.emeraldGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.deepCharcoal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.gray600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<SearchProvider>().refresh();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.emeraldGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: AppTheme.gray400),
            const SizedBox(height: 16),
            Text(
              'No Results Found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.deepCharcoal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We couldn\'t find any PGs matching your search criteria. Try adjusting your filters or search terms.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.gray600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (context.read<SearchProvider>().hasFiltersApplied)
              ElevatedButton(
                onPressed: () {
                  context.read<SearchProvider>().clearFilters();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.emeraldGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Clear Filters'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(SearchProvider provider) {
    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount:
              provider.searchResults.length + 1, // +1 for loading indicator
          itemBuilder: (context, index) {
            if (index == provider.searchResults.length) {
              // Show loading indicator at the end if more data is loading
              if (provider.isLoadingMore) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else {
                return const SizedBox.shrink();
              }
            }

            // Show PG card
            final pg = provider.searchResults[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PGCard(
                pgProperty: pg,
                variant: PGCardVariant.detailed,
                onTap: () => _navigateToPGDetail(pg.id),
                onWishlistTap: () {
                  // Wishlist functionality would be implemented here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Wishlist feature coming soon!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                onContactTap: () {
                  // Contact functionality would be implemented here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Contact feature coming soon!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            );
          },
        ),

        // Show loading indicator overlay when first loading
        if (provider.isLoading && !provider.isLoadingMore)
          Container(
            color: Colors.white.withOpacity(0.5),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  void _navigateToPGDetail(String pgId) {
    Navigator.pushNamed(context, AppConstants.pgDetailRoute, arguments: pgId);
  }
}
