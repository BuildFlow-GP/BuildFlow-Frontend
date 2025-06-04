import 'package:buildflow_frontend/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../models/Basic/project_model.dart';
import '../../services/chosen_office_service.dart';
import '../../services/project_service.dart';
import 'no_permit_screen.dart';

final logger = Logger();

class ChooseOfficeScreen extends StatefulWidget {
  const ChooseOfficeScreen({super.key});

  @override
  State<ChooseOfficeScreen> createState() => _ChooseOfficeScreenState();
}

class _ChooseOfficeScreenState extends State<ChooseOfficeScreen> {
  List<Office> _offices = [];
  List<Office> _filteredOffices = [];
  bool _isLoading = true;
  String _searchQuery = '';
  Office? _selectedOffice;

  @override
  void initState() {
    super.initState();
    _loadOffices();
  }

  Future<void> _loadOffices() async {
    final offices = await OfficeService.fetchSuggestedOffices();
    setState(() {
      _offices = offices;
      _filteredOffices = offices;
      _isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredOffices =
          _offices.where((office) {
            return office.name.toLowerCase().contains(_searchQuery) ||
                office.location.toLowerCase().contains(_searchQuery);
          }).toList();
      // Reset selection if filtered list does not contain the selected office
      if (_selectedOffice != null &&
          !_filteredOffices.contains(_selectedOffice)) {
        _selectedOffice = null;
      }
    });
  }

  void _onOfficeTapped(Office office) {
    setState(() {
      _selectedOffice = office;
    });
    logger.i('Tapped office: ${office.name}');
  }

  bool _isSubmittingRequest = false;
  bool get isSubmittingRequest => _isSubmittingRequest;
  void _onNextPressed() async {
    if (_selectedOffice == null) return;

    setState(() {
      _isSubmittingRequest = true; // إظهار التحميل
    });

    try {
      // يمكنكِ جمع projectType و initialDescription من المستخدم هنا إذا لزم الأمر
      // أو استخدام قيم افتراضية مؤقتاً للاختبار
      String projectType = "Initial Design Request"; // مثال، يجب تغييره
      String? initialDescription =
          "User is requesting an initial design from ${_selectedOffice!.name}."; // مثال

      // استدعاء السيرفس لإرسال الطلب
      final ProjectService projectService = ProjectService();
      final ProjectModel initialProject = await projectService
          .requestInitialProject(
            officeId: _selectedOffice!.id,
            projectType: projectType,
            initialDescription: initialDescription,
          );

      // نجاح
      if (mounted) {
        logger.i(
          'Initial project request sent successfully for office: ${_selectedOffice!.name}, Project ID: ${initialProject.id}',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Project request sent to ${_selectedOffice!.name}. Waiting for approval.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // يمكنكِ الانتقال إلى شاشة الهوم أو شاشة "مشاريعي"
        // Get.offAll(() => HomeScreen()); // مثال باستخدام GetX للانتقال للهوم
        Navigator.of(context).popUntil(
          (route) => route.isFirst,
        ); // العودة للشاشة الأولى (الهوم عادة)
      }
    } catch (e) {
      // فشل
      if (mounted) {
        logger.e('Failed to send project request: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send request: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingRequest = false; // إخفاء التحميل
        });
      }
    }
  }

  // void _onNextPressed() {
  //   // if (_selectedOffice != null) {
  //   //   logger.i('Selected office confirmed: ${_selectedOffice!.name}');
  //   //   Navigator.push(
  //   //     context,
  //   //     MaterialPageRoute(builder: (context) => NoPermitScreen()),
  //   //   );
  //   // }

  // }

  Widget _buildOfficeCard(Office office, double cardWidth) {
    final bool isSelected = _selectedOffice == office;
    return GestureDetector(
      onTap: () => _onOfficeTapped(office),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: cardWidth,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color:
              isSelected ? AppColors.primary.withOpacity(0.2) : AppColors.card,
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                office.imageUrl.isNotEmpty
                    ? office.imageUrl
                    : 'https://via.placeholder.com/80',
                width: cardWidth * 0.2,
                height: cardWidth * 0.2,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    office.name,
                    style: TextStyle(
                      fontSize: cardWidth > 400 ? 18 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    office.location,
                    style: TextStyle(fontSize: cardWidth > 400 ? 14 : 12),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        office.rating.toString(),
                        style: TextStyle(fontSize: cardWidth > 400 ? 14 : 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Adjust card width based on screen size (responsive)
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth > 600 ? 600 : screenWidth * 0.9;

    return Scaffold(
      appBar: null,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 28),
                  color: AppColors.accent,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Text(
                    "Choose an Office",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                      letterSpacing: 0.8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // توازن المساحة بسبب زر الرجوع
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  _isLoading
                      ? _buildLoadingAnimation(context)
                      : Column(
                        children: [
                          TextField(
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              labelText: 'Search Office',
                              hintText: 'Search by name or location',
                              prefixIcon: Icon(
                                Icons.search,
                                color: AppColors.accent,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.accent,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: AppColors.card,
                              labelStyle: TextStyle(
                                color: AppColors.textSecondary,
                              ),
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary.withOpacity(0.6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child:
                                _filteredOffices.isEmpty
                                    ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.search_off,
                                          size: 60,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No offices found',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Try different search terms',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        OutlinedButton(
                                          onPressed: () => _onSearchChanged(''),
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                              color: AppColors.accent,
                                            ),
                                          ),
                                          child: Text(
                                            'Clear search',
                                            style: TextStyle(
                                              color: AppColors.accent,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                    : ListView.builder(
                                      itemCount: _filteredOffices.length,
                                      itemBuilder: (context, index) {
                                        final office = _filteredOffices[index];
                                        return Center(
                                          child: _buildOfficeCard(
                                            office,
                                            cardWidth,
                                          ),
                                        );
                                      },
                                    ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed:
                                _selectedOffice == null ? null : _onNextPressed,
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(cardWidth, 50),
                              backgroundColor:
                                  _selectedOffice != null
                                      ? AppColors.accent
                                      : Colors.grey.shade400,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              shadowColor: AppColors.accent.withOpacity(0.3),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              _selectedOffice == null
                                  ? 'Select an office to continue'
                                  : 'Next',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingAnimation(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(
            turns: AlwaysStoppedAnimation(0.5), // نصف دورة ثابتة
            child: FadeTransition(
              opacity: Tween(begin: 0.5, end: 1.0).animate(
                CurvedAnimation(
                  parent: ModalRoute.of(context)!.animation!,
                  curve: Curves.easeInOut,
                ),
              ),
              child: Icon(Icons.autorenew, color: AppColors.accent, size: 50),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading offices...',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
