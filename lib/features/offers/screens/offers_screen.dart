// lib/features/offers/screens/offers_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/offers_provider.dart';
// Import the models from shared location instead of defining them in this file
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
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
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
          tabs: const [
            Tab(text: 'Offers'),
            Tab(text: 'Coupons'),
            Tab(text: 'Refer & Earn'),
          ],
        ),
      ),
      pinned: true,
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
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

  Widget _buildOfferCard(Offer offer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
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
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    offer.discountText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
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
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 12,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'EXCLUSIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Expiry overlay
              if (offer.expiryDate != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Text(
                      'Expires in ${_getDaysRemaining(offer.expiryDate!)} days',
                      style: const TextStyle(
                        color: Colors.white,
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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepCharcoal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  offer.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.gray700,
                  ),
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showOfferTerms(offer),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.emeraldGreen),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'VIEW TERMS',
                          style: TextStyle(color: AppTheme.emeraldGreen),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _redeemOffer(offer),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.emeraldGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('REDEEM NOW'),
                      ),
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

  Widget _buildCouponsTab(OffersProvider provider) {
    final coupons = provider.coupons;

    if (coupons.isEmpty) {
      return _buildEmptyState(
        icon: Icons.confirmation_number_outlined,
        title: 'No coupons available',
        message: 'Check back soon for exclusive discount coupons',
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

  Widget _buildCouponCard(Coupon coupon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: coupon.isValid ? Colors.grey.shade200 : Colors.red.shade100,
        ),
      ),
      color: coupon.isValid ? Colors.white : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Coupon icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: coupon.isValid
                        ? AppTheme.emeraldGreen.withOpacity(0.1)
                        : Colors.red.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.confirmation_number_outlined,
                    color: coupon.isValid
                        ? AppTheme.emeraldGreen
                        : Colors.red[300],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coupon.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: coupon.isValid
                              ? AppTheme.deepCharcoal
                              : Colors.red[300],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coupon.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.gray700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Coupon code
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: coupon.isValid
                    ? AppTheme.gray100
                    : Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: coupon.isValid
                      ? Colors.grey.shade300
                      : Colors.red.shade200,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    coupon.code,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: coupon.isValid
                          ? AppTheme.emeraldGreen
                          : Colors.red[300],
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (coupon.isValid)
                    GestureDetector(
                      onTap: () {
                        // Copy to clipboard
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Coupon code copied to clipboard'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppTheme.emeraldGreen,
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.copy_outlined,
                        size: 16,
                        color: AppTheme.emeraldGreen,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Validity info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  coupon.isValid
                      ? 'Valid till: ${coupon.expiryDate != null ? _formatDate(coupon.expiryDate!) : 'No expiry'}'
                      : 'EXPIRED',
                  style: TextStyle(
                    fontSize: 12,
                    color: coupon.isValid ? AppTheme.gray600 : Colors.red[300],
                  ),
                ),
                if (coupon.isValid)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppConstants.searchRoute);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.emeraldGreen,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text('USE NOW'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralsTab(OffersProvider provider) {
    return RefreshIndicator(
      onRefresh: provider.refresh,
      color: AppTheme.emeraldGreen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Referral program info
            _buildReferralProgramCard(provider),
            const SizedBox(height: 24),

            // Referrals list
            if (provider.referrals.isNotEmpty) ...[
              Text(
                'Your Referrals',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepCharcoal,
                    ),
              ),
              const SizedBox(height: 16),
              ...provider.referrals.map(
                (referral) => _buildReferralListItem(referral),
              ),
            ] else
              _buildEmptyReferrals(),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralProgramCard(OffersProvider provider) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            AppTheme.emeraldGreen,
            AppTheme.emeraldGreen.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.emeraldGreen.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.card_giftcard,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'REFER & EARN',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Refer a friend and both get ₹${provider.referralBonus.toInt()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Share your referral code with friends and earn ₹${provider.referralBonus.toInt()} when they complete their first booking',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                // Referral code
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your Referral Code',
                              style: TextStyle(
                                color: AppTheme.gray600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              provider.referralCode,
                              style: const TextStyle(
                                color: AppTheme.deepCharcoal,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Copy to clipboard
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Referral code copied to clipboard'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppTheme.emeraldGreen,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.deepCharcoal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        child: const Text('COPY'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Share section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShareButton(
                    'WhatsApp', Icons.wechat_outlined, Colors.green),
                _buildShareButton('SMS', Icons.sms, Colors.blue),
                _buildShareButton('Email', Icons.email, Colors.orange),
                _buildShareButton('More', Icons.more_horiz, Colors.purple),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton(String label, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sharing via $label'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.emeraldGreen,
          ),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.gray700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralListItem(Referral referral) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              backgroundColor: AppTheme.emeraldGreen.withOpacity(0.1),
              child: Text(
                referral.name.isNotEmpty ? referral.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: AppTheme.emeraldGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    referral.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Joined ${_formatDate(referral.joinedDate)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.gray600,
                    ),
                  ),
                ],
              ),
            ),
            // Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: referral.isComplete
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    referral.isComplete ? 'COMPLETED' : 'PENDING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: referral.isComplete ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${referral.bonusAmount.toInt()}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: referral.isComplete
                        ? AppTheme.emeraldGreen
                        : AppTheme.gray600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyReferrals() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          const Icon(
            Icons.people_outline,
            size: 64,
            color: AppTheme.gray400,
          ),
          const SizedBox(height: 16),
          Text(
            'No referrals yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepCharcoal,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Share your code with friends and earn rewards',
            style: TextStyle(
              color: AppTheme.gray600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
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
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepCharcoal,
                ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.gray600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOfferTerms(Offer offer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Conditions'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ...offer.terms.map((term) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(child: Text(term)),
                      ],
                    ),
                  )),
            ],
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

  void _showReferralTerms() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Referral Program Terms'),
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
      const SnackBar(
        content: Text('Redirecting to PG booking'),
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

// The model definitions for Offer, Coupon, and Referral have been moved to app_models.dart
// and are now imported from there
