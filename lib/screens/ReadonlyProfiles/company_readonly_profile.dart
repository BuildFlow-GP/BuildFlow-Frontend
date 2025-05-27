// screens/profiles/company_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import '../../models/company_model.dart';
import '../../models/project_model.dart';
import '../../models/review_model.dart'; // استخدام ReviewModel الخاص بكِ (الذي اسمه Review)
import '../../services/ReadonlyProfiles/company_readonly.dart';
import '../../services/session.dart';
import 'project_readonly_profile.dart';

class CompanyrProfileScreen extends StatefulWidget {
  final int companyId;
  // isOwner يمكن تحديده ديناميكياً، سأفترض حالياً أنه يمرر
  // إذا كان companyId هو نفسه userId للمالك، أو إذا كان CompanyModel يحتوي على userId للمالك
  final bool isOwner;

  const CompanyrProfileScreen({
    super.key,
    required this.companyId,
    this.isOwner = false,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CompanyrProfileScreenState createState() => _CompanyrProfileScreenState();
}

class _CompanyrProfileScreenState extends State<CompanyrProfileScreen> {
  final CompanyProfileService _profileService = CompanyProfileService();
  CompanyModel? _company;
  List<ProjectModel> _projects = [];
  List<Review> _reviews = []; // تم تغيير اسم الكلاس

  bool _isLoadingCompany = true;
  bool _isLoadingProjects = true;
  bool _isLoadingReviews = true;

  String? _companyError;
  String? _projectsError;
  String? _reviewsError;

  int? _currentUserId;
  bool _isActuallyOwner = false; // سيتم تحديده ديناميكياً

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadCurrentUserIdAndDetermineOwnership();
    _fetchAllData();
  }

  Future<void> _loadCurrentUserIdAndDetermineOwnership() async {
    _currentUserId = await Session.getUserId();
    // لتحديد الملكية الفعلية، نحتاج لحقل user_id في CompanyModel
    // يمثل مالك الشركة، أو أن company.id هو نفسه user_id للمالك.
    // سأفترض أننا نعتمد على widget.isOwner حالياً.
    _isActuallyOwner = widget.isOwner;
    if (mounted) setState(() {});
  }

  Future<void> _fetchAllData() async {
    _fetchCompanyDetails();
    _fetchCompanyProjects();
    _fetchCompanyReviews();
  }

  Future<void> _fetchCompanyDetails() async {
    if (!mounted) return;
    setState(() => _isLoadingCompany = true);
    try {
      final companyData = await _profileService.getCompanyDetails(
        widget.companyId,
      );
      if (mounted) {
        // إذا كان CompanyModel يحتوي على user_id للمالك:
        // if (_currentUserId != null && companyData.userId == _currentUserId) { // مثال
        //   _isActuallyOwner = true;
        // }
        setState(() {
          _company = companyData;
          _isLoadingCompany = false;
          _companyError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCompany = false;
          _companyError = e.toString();
        });
      }
      print("Error fetching company details: $e");
    }
  }

  Future<void> _fetchCompanyProjects() async {
    if (!mounted) return;
    setState(() => _isLoadingProjects = true);
    try {
      final projectsData = await _profileService.getCompanyProjects(
        widget.companyId,
      );
      if (mounted) {
        setState(() {
          _projects = projectsData;
          _isLoadingProjects = false;
          _projectsError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProjects = false;
          _projectsError = e.toString();
        });
      }
      print("Error fetching company projects: $e");
    }
  }

  Future<void> _fetchCompanyReviews() async {
    if (!mounted) return;
    setState(() => _isLoadingReviews = true);
    try {
      final reviewsData = await _profileService.getCompanyReviews(
        widget.companyId,
      );
      if (mounted) {
        setState(() {
          _reviews = reviewsData;
          _isLoadingReviews = false;
          _reviewsError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingReviews = false;
          _reviewsError = e.toString();
        });
      }
      print("Error fetching company reviews: $e");
    }
  }

  void _showAddReviewDialog() {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add a review.')),
      );
      return;
    }
    // افترض أن _company.user_id هو ID المستخدم المالك للشركة.
    // إذا كان CompanyModel يحتوي على حقل user_id يربطه بمالك الشركة.
    // if (_company?.userId == _currentUserId) { // مثال، عدلي حسب نموذجك
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('You cannot review your own company.')),
    //   );
    //   return;
    // }

    final TextEditingController commentController = TextEditingController();
    double ratingValue = 3.0;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Add Your Review'),
          content: SingleChildScrollView(
            /* ... نفس كود محتوى النافذة ... */
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RatingBar.builder(
                  initialRating: ratingValue,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder:
                      (context, _) =>
                          const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (rating) => ratingValue = rating,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    hintText: 'Write your comment (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            /* ... نفس كود أزرار النافذة ... */
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: const Text('Submit'),
              onPressed: () async {
                try {
                  await _profileService.addReview(
                    companyId: widget.companyId,
                    rating: ratingValue.toInt(),
                    comment:
                        commentController.text.trim().isEmpty
                            ? null
                            : commentController.text.trim(),
                  );
                  Navigator.of(dialogContext).pop();
                  _fetchCompanyReviews();
                  _fetchCompanyDetails(); // لتحديث متوسط التقييم
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Review submitted successfully!'),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to submit review: ${e.toString()}',
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canEdit = _isActuallyOwner;

    return Scaffold(
      appBar: AppBar(
        title: Text(_company?.name ?? 'Company Profile'),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit profile functionality coming soon!'),
                  ),
                );
              },
            ),
        ],
      ),
      body:
          (_isLoadingCompany && _company == null)
              ? const Center(child: CircularProgressIndicator())
              : (_companyError != null && _company == null)
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _companyError!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadInitialData,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildCompanyInfoSection(),
                    const SizedBox(height: 24),
                    _buildProjectsSection(),
                    const SizedBox(height: 24),
                    _buildReviewsSection(),
                    const SizedBox(height: 70),
                  ],
                ),
              ),
      floatingActionButton:
          _currentUserId != null && _company != null && !_isActuallyOwner
              ? FloatingActionButton.extended(
                onPressed: _showAddReviewDialog,
                label: const Text('Add Review'),
                icon: const Icon(Icons.rate_review_outlined),
              )
              : null,
    );
  }

  Widget _buildCompanyInfoSection() {
    if (_company == null) return const SizedBox.shrink();

    return Card(
      /* ... نفس تصميم Card المعلومات الأساسية مع تعديل الحقول لـ CompanyModel ... */
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        (_company!.profileImage != null &&
                                _company!.profileImage!.isNotEmpty)
                            ? NetworkImage(_company!.profileImage!)
                            : null,
                    onBackgroundImageError: (exception, stackTrace) {
                      print('Error loading company profile image: $exception');
                    },
                    child:
                        (_company!.profileImage == null ||
                                _company!.profileImage!.isEmpty)
                            ? const Icon(
                              Icons.business_center,
                              size: 50,
                            ) // أيقونة مختلفة للشركة
                            : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _company!.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_company!.rating != null && _company!.rating! > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        /* ... نفس كود عرض النجوم ... */
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RatingBarIndicator(
                            rating: _company!.rating!,
                            itemBuilder:
                                (context, index) =>
                                    const Icon(Icons.star, color: Colors.amber),
                            itemCount: 5,
                            itemSize: 22.0,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${_company!.rating!.toStringAsFixed(1)})',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  if (_company!.companyType != null &&
                      _company!.companyType!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Center(
                        child: Chip(label: Text(_company!.companyType!)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            if (_company!.description != null &&
                _company!.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _company!.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            if (_company!.location != null && _company!.location!.isNotEmpty)
              _buildInfoRow(
                Icons.location_on_outlined,
                'Location',
                _company!.location!,
              ),
            if (_company!.email != null && _company!.email!.isNotEmpty)
              _buildInfoRow(Icons.email_outlined, 'Email', _company!.email!),
            if (_company!.phone != null && _company!.phone!.isNotEmpty)
              _buildInfoRow(Icons.phone_outlined, 'Phone', _company!.phone!),
            if (_company!.staffCount != null && _company!.staffCount! > 0)
              _buildInfoRow(
                Icons.people_outline,
                'Staff Count',
                _company!.staffCount.toString(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    /* ... نفس الكود ... */
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsSection() {
    /* ... نفس كود عرض المشاريع، مع تعديل النصوص إذا لزم الأمر ... */
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Our Projects',
            style: Theme.of(context).textTheme.titleLarge,
          ), // تغيير العنوان
        ),
        if (_isLoadingProjects)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_projectsError != null)
          Center(
            child: Text(
              _projectsError!,
              style: const TextStyle(color: Colors.red),
            ),
          )
        else if (_projects.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No projects to display for this company.'),
            ),
          ) // تغيير النص
        else
          SizedBox(
            /* ... نفس كود ListView.builder للمشاريع ... */
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _projects.length,
              itemBuilder: (context, index) {
                final project = _projects[index];
                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ProjectreadDetailsScreen(
                                  projectId: project.id,
                                ),
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Tapped on ${project.name}')),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            if (project.description != null &&
                                project.description!.isNotEmpty)
                              Text(
                                project.description!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  label: Text(
                                    project.status ?? 'N/A',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ),
                                if (project.endDate != null &&
                                    DateTime.tryParse(project.endDate!) != null)
                                  Text(
                                    'Due: ${DateFormat.yMd().format(DateTime.parse(project.endDate!))}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    /* ... نفس كود عرض المراجعات، باستخدام ReviewModel الخاص بكِ ... */
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Client Reviews',
            style: Theme.of(context).textTheme.titleLarge,
          ), // تغيير العنوان
        ),
        if (_isLoadingReviews)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_reviewsError != null)
          Center(
            child: Text(
              _reviewsError!,
              style: const TextStyle(color: Colors.red),
            ),
          )
        else if (_reviews.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No reviews yet for this company.'),
            ),
          ) // تغيير النص
        else
          ListView.separated(
            /* ... نفس كود ListView.separated للمراجعات ... */
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _reviews.length,
            itemBuilder: (context, index) {
              final review = _reviews[index];
              return Card(
                elevation: 1,
                margin: const EdgeInsets.symmetric(vertical: 5.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              review.userName ?? 'Anonymous Client',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ), // تغيير النص
                          RatingBarIndicator(
                            rating: review.rating.toDouble(),
                            itemBuilder:
                                (context, _) =>
                                    const Icon(Icons.star, color: Colors.amber),
                            itemCount: 5,
                            itemSize: 18.0,
                          ),
                        ],
                      ),
                      if (review.comment != null && review.comment!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                          child: Text(review.comment!),
                        ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          DateFormat.yMMMd().format(review.reviewedAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 8),
          ),
      ],
    );
  }
}
