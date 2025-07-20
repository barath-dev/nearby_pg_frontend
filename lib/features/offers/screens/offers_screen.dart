import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/offers_provider.dart';
import '../../../shared/models/app_models.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize offers data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OffersProvider>().initialize();
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    setState(() {
      _isScrolled = _scrollController.offset > 10;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: Consumer<OffersProvider>(
        builder: (context, provider, child) {
          return NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _buildAppBar(innerBoxIsScrolled),
              _buildTabBar(),
            ],
            body: provider.isLoading
                ? _buildLoadingState()
                : provider.hasError
                    ? _buildErrorState(provider)
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOffersTab(provider),
                          _buildCouponsTab(provider),
                          _buildReferralsTab(provider),
                        ],
                      ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(bool isScrolled) {
    return SliverAppBar(
      expandedHeight: 130.0,
      floating: true,
      pinned: true,
      elevation: _isScrolled ? 2 : 0,
      backgroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Offers & Deals',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.deepCharcoal,
                fontWeight: FontWeight.w700,
              ),
        ),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 70),
        expandedTitleScale: 1.3,
        background: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: _isScrolled
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 70, 20, 0),
                child: Text(
                  'Exclusive offers to save on your next PG booking',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.gray600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SliverPersistentHeader(
      delegate: _SliverAppBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.emeraldGreen,
          unselectedLabelColor: AppTheme.gray600,
          indicatorColor: AppTheme.emeraldGreen,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'PG OFFERS'),
            Tab(text: 'COUPONS'),
            Tab(text: 'REFERRALS'),
          ],
        ),
      ),
      pinned: true,
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              height: 180,
              width: double.infinity,
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(OffersProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            provider.errorMessage,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: provider.refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.emeraldGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersTab(OffersProvider provider) {
    final offers = provider.pgOffers;

    if (offers.isEmpty) {
      return _buildEmptyState(
        icon: Icons.local_offer,
        title: 'No offers available',
        message: 'Check back later for exciting deals on PGs',
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      color: AppTheme.emeraldGreen,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];
          return _buildOfferCard(offer);
        },
      ),
    );
  }

  Widget _buildCouponsTab(OffersProvider provider) {
    final coupons = provider.coupons;

    if (coupons.isEmpty) {
      return _buildEmptyState(
        icon: Icons.card_giftcard,
        title: 'No coupons available',
        message: 'Check back later for discount coupons',
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      color: AppTheme.emeraldGreen,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: coupons.length,
        itemBuilder: (context, index) {
          final coupon = coupons[index];
          return _buildCouponCard(coupon);
        },
      ),
    );
  }

  Widget _buildReferralsTab(OffersProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildReferralCard(provider),
          const SizedBox(height: 24),
          _buildReferralHistory(provider),
        ],
      ),
    );
  }

  Widget _buildOfferCard(Offer offer) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Offer image with overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  offer.imageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 140,
                      color: AppTheme.lightMint.withOpacity(0.3),
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: AppTheme.gray400,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (offer.isExclusive)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.emeraldGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'EXCLUSIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              if (offer.expiryDate != null)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Expires in ${_getDaysRemaining(offer.expiryDate!)} days',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Offer details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.deepCharcoal,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  offer.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.gray700,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Discount badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red[100]!),
                      ),
                      child: Text(
                        offer.discountText,
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    // Apply button
                    TextButton(
                      onPressed: () {
                        _showOfferDetails(offer);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.emeraldGreen,
                      ),
                      child: const Text('VIEW DETAILS'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard(Coupon coupon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: coupon.isValid
                ? [AppTheme.emeraldGreen.withOpacity(0.1), Colors.white]
                : [Colors.grey[300]!, Colors.white],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Coupon icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: coupon.isValid
                          ? AppTheme.emeraldGreen.withOpacity(0.1)
                          : Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_offer,
                      size: 24,
                      color:
                          coupon.isValid ? AppTheme.emeraldGreen : Colors.grey,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Coupon details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coupon.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: coupon.isValid
                                        ? AppTheme.deepCharcoal
                                        : Colors.grey,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          coupon.description,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: coupon.isValid
                                        ? AppTheme.gray600
                                        : Colors.grey,
                                  ),
                        ),
                        const SizedBox(height: 8),

                        // Validity info
                        if (coupon.isValid && coupon.expiryDate != null)
                          Text(
                            'Valid till ${_formatDate(coupon.expiryDate!)}',
                            style: TextStyle(
                              color: AppTheme.emeraldGreen,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          )
                        else if (!coupon.isValid)
                          Text(
                            'Expired',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Coupon code section with dotted border
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Coupon code
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      coupon.code,
                      style: TextStyle(
                        color: AppTheme.deepCharcoal,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  // Copy button
                  TextButton.icon(
                    onPressed: coupon.isValid
                        ? () => _copyCouponCode(coupon.code)
                        : null,
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('COPY'),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          coupon.isValid ? AppTheme.emeraldGreen : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Apply button
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: coupon.isValid ? () => _applyCoupon(coupon) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.emeraldGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    coupon.isValid ? 'APPLY' : 'EXPIRED',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralCard(OffersProvider provider) {
    final referralCode = provider.referralCode;
    final referralBonus = provider.referralBonus;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Refer & Earn',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.emeraldGreen,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Invite friends to NEARBY PG and earn ₹$referralBonus when they complete their first booking!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.gray700,
                  ),
            ),
            const SizedBox(height: 24),

            // Referral code section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.emeraldGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.emeraldGreen.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Referral Code',
                    style: TextStyle(
                      color: AppTheme.gray600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          referralCode,
                          style: TextStyle(
                            color: AppTheme.emeraldGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _copyReferralCode(referralCode),
                        icon: const Icon(
                          Icons.copy,
                          color: AppTheme.emeraldGreen,
                        ),
                        tooltip: 'Copy Code',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Share buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _shareReferralCode(referralCode),
                    icon: const Icon(Icons.share),
                    label: const Text('SHARE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.emeraldGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showReferralTerms(),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('TERMS'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.emeraldGreen,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: AppTheme.emeraldGreen),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralHistory(OffersProvider provider) {
    final referrals = provider.referrals;

    if (referrals.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Referral History',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepCharcoal,
                    ),
              ),
              const SizedBox(height: 40),
              const Icon(
                Icons.people_outline,
                size: 64,
                color: AppTheme.gray400,
              ),
              const SizedBox(height: 16),
              Text(
                'No referrals yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.gray600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Share your referral code with friends to start earning rewards',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.gray600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Referral History',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepCharcoal,
                  ),
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: referrals.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final referral = referrals[index];
              return ListTile(
                title: Text(
                  referral.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Joined on ${_formatDate(referral.joinedDate)}',
                ),
                trailing: referral.isComplete
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '+ ₹${referral.bonusAmount}',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Earned',
                            style: TextStyle(
                              color: AppTheme.gray600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Pending',
                        style: TextStyle(
                          color: Colors.orange,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppTheme.gray400,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.deepCharcoal,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.gray600,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showOfferDetails(Offer offer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Image
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    offer.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.lightMint.withOpacity(0.3),
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: AppTheme.gray400,
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.7, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Text(
                      offer.title,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Discount badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red[100]!),
                      ),
                      child: Text(
                        offer.discountText,
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Description
                    Text(
                      'About this offer',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.deepCharcoal,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      offer.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.gray700,
                            height: 1.5,
                          ),
                    ),

                    const SizedBox(height: 24),

                    // Terms
                    Text(
                      'Terms & Conditions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.deepCharcoal,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: offer.terms.map((term) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• '),
                              Expanded(
                                child: Text(
                                  term,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppTheme.gray700,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Validity
                    if (offer.expiryDate != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 20,
                              color: AppTheme.gray600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Valid till ${_formatDate(offer.expiryDate!)}',
                              style: const TextStyle(
                                color: AppTheme.gray700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Apply button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _redeemOffer(offer),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.emeraldGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'REDEEM OFFER',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyCouponCode(String code) {
    // In a real app, would use Clipboard.setData
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Coupon code $code copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.emeraldGreen,
      ),
    );
  }

  void _applyCoupon(Coupon coupon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Coupon ${coupon.code} applied successfully'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.emeraldGreen,
      ),
    );
    Navigator.pushNamed(context, AppConstants.searchRoute);
  }

  void _copyReferralCode(String code) {
    // In a real app, would use Clipboard.setData
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Referral code $code copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.emeraldGreen,
      ),
    );
  }

  void _shareReferralCode(String code) {
    // In a real app, would use share package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sharing referral code'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.emeraldGreen,
      ),
    );
  }

  void _showReferralTerms() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Referral Terms & Conditions'),
        content: const SingleChildScrollView(
          child: Text(
            '1. Both referrer and referee get ₹500 when the referee completes their first booking.\n\n'
            '2. The booking must be for at least 1 month.\n\n'
            '3. The referral bonus will be credited to your wallet within 7 days after the referee completes their stay of at least 1 month.\n\n'
            '4. Maximum referral bonus that can be earned is ₹5000 per user.\n\n'
            '5. NEARBY PG reserves the right to change the terms and conditions of the referral program at any time without prior notice.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  void _redeemOffer(Offer offer) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Redirecting to PG booking'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.emeraldGreen,
      ),
    );
    Navigator.pushNamed(context, AppConstants.searchRoute);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  int _getDaysRemaining(DateTime expiryDate) {
    final now = DateTime.now();
    return expiryDate.difference(now).inDays;
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}

// Models for Offers screen

class Offer {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String discountText;
  final bool isExclusive;
  final DateTime? expiryDate;
  final List<String> terms;
  final String? couponCode;

  const Offer({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.discountText,
    this.isExclusive = false,
    this.expiryDate,
    required this.terms,
    this.couponCode,
  });
}

class Coupon {
  final String id;
  final String code;
  final String title;
  final String description;
  final DateTime? expiryDate;
  final bool isValid;

  const Coupon({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    this.expiryDate,
    this.isValid = true,
  });
}

class Referral {
  final String id;
  final String name;
  final DateTime joinedDate;
  final bool isComplete;
  final double bonusAmount;

  const Referral({
    required this.id,
    required this.name,
    required this.joinedDate,
    required this.isComplete,
    required this.bonusAmount,
  });
}
