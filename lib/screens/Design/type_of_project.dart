/*import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'choose_office.dart'; // Import the choose office screen

class TypeOfProjectPage extends StatelessWidget {
  const TypeOfProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> projectTypes = ["Design", "Supervision", "Consultation"];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back(); // Navigate back to previous screen (HomeScreen)
          },
        ),
        title: const Row(
          children: [
            Icon(Icons.category),
            SizedBox(width: 10),
            Text("Choose Project"),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: projectTypes.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              leading: const Icon(Icons.build),
              title: Text(projectTypes[index]),
              onTap: () {
                Get.to(() => const ChooseOfficeScreen());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Selected: ${projectTypes[index]}")),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
*/

import 'package:buildflow_frontend/screens/Design/choose_office.dart';
import 'package:buildflow_frontend/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buildflow_frontend/widgets/navbar.dart';

class TypeOfProjectPage extends StatelessWidget {
  const TypeOfProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Column(
        children: [
          // == Navbar ==
          const Navbar(),
          const SizedBox(height: 20),

          // == العنوان ==
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // زر الرجوع
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: AppColors.accent, // لون متناسق مع التصميم
                  onPressed: () {
                    Get.back(); // العودة إلى الشاشة السابقة
                  },
                ),
                // العنوان مع الأيقونة (يأخذ المساحة المتبقية)
                Expanded(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.category, color: AppColors.accent),
                        SizedBox(width: 10),
                        Text(
                          "Choose Project Type",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // عنصر فارغ للحفاظ على التوازن (بنفس عرض زر الرجوع)
                const SizedBox(width: 48), // نفس عرض IconButton تقريباً
              ],
            ),
          ),
          // == القائمة ==
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // عرض شاشة الموبايل (أقل من 600 بكسل)
                if (constraints.maxWidth < 600) {
                  return ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    children: const [
                      // بطاقة Design
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: _DesignCardMobile(),
                      ),
                      // بطاقة Supervision
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: _SupervisionCardMobile(),
                      ),
                      // بطاقة Consultation
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: _ConsultationCardMobile(),
                      ),
                    ],
                  );
                }
                // عرض شاشة الأجهزة الكبيرة (أكبر من 600 بكسل)
                else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: _DesignCard(),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: _SupervisionCard(),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: _ConsultationCard(),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================
// بطاقات الأجهزة الكبيرة
// =============================================

class _DesignCard extends StatelessWidget {
  const _DesignCard();

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: 1.0,
      child: _HoverEffect(
        child: GestureDetector(
          onTap: () {
            // الانتقال إلى صفحة Design المخصصة
            Get.to(() => const ChooseOfficeScreen());
          },
          child: Hero(
            tag: 'project_Design',
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // الصورة المربعة التي تشغل المساحة بالكامل
                  Expanded(
                    child: Image(
                      image: AssetImage('assets/design.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  // نص البطاقة
                  _CardTitle(title: 'Design'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SupervisionCard extends StatelessWidget {
  const _SupervisionCard();

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: 1.0,
      child: _HoverEffect(
        child: GestureDetector(
          onTap: () {
            // الانتقال إلى صفحة Supervision المخصصة
            Get.toNamed('/supervision-page');
          },
          child: Hero(
            tag: 'project_Supervision',
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // الصورة المربعة التي تشغل المساحة بالكامل
                  Expanded(
                    child: Image(
                      image: AssetImage('assets/supervision.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  // نص البطاقة
                  _CardTitle(title: 'Supervision'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConsultationCard extends StatelessWidget {
  const _ConsultationCard();

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: 1.0,
      child: _HoverEffect(
        child: GestureDetector(
          onTap: () {
            // الانتقال إلى صفحة Consultation المخصصة
            Get.toNamed('/consultation-page');
          },
          child: Hero(
            tag: 'project_Consultation',
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // الصورة المربعة التي تشغل المساحة بالكامل
                  Expanded(
                    child: Image(
                      image: AssetImage('assets/consultation.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  // نص البطاقة
                  _CardTitle(title: 'Consultation'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================
// بطاقات الموبايل
// =============================================

class _DesignCardMobile extends StatelessWidget {
  const _DesignCardMobile();

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: 1.0,
      child: _HoverEffect(
        child: GestureDetector(
          onTap: () {
            // الانتقال إلى صفحة Design المخصصة
            Get.to(() => const ChooseOfficeScreen());
          },
          child: Hero(
            tag: 'project_Design',
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: const Row(
                children: [
                  // الصورة المربعة للموبايل
                  _MobileCardImage(imagePath: 'assets/design.jpg'),
                  // نص البطاقة
                  _MobileCardTitle(title: 'Design'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SupervisionCardMobile extends StatelessWidget {
  const _SupervisionCardMobile();

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: 1.0,
      child: _HoverEffect(
        child: GestureDetector(
          onTap: () {
            // الانتقال إلى صفحة Supervision المخصصة
            Get.toNamed('/supervision-page');
          },
          child: Hero(
            tag: 'project_Supervision',
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: const Row(
                children: [
                  // الصورة المربعة للموبايل
                  _MobileCardImage(imagePath: 'assets/supervision.jpg'),
                  // نص البطاقة
                  _MobileCardTitle(title: 'Supervision'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConsultationCardMobile extends StatelessWidget {
  const _ConsultationCardMobile();

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: 1.0,
      child: _HoverEffect(
        child: GestureDetector(
          onTap: () {
            // الانتقال إلى صفحة Consultation المخصصة
            Get.toNamed('/consultation-page');
          },
          child: Hero(
            tag: 'project_Consultation',
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: const Row(
                children: [
                  // الصورة المربعة للموبايل
                  _MobileCardImage(imagePath: 'assets/consultation.jpg'),
                  // نص البطاقة
                  _MobileCardTitle(title: 'Consultation'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================
// مكونات مشتركة
// =============================================

class _CardTitle extends StatelessWidget {
  final String title;
  const _CardTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _MobileCardImage extends StatelessWidget {
  final String imagePath;
  const _MobileCardImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Image(image: AssetImage(imagePath), fit: BoxFit.cover),
    );
  }
}

class _MobileCardTitle extends StatelessWidget {
  final String title;
  const _MobileCardTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// == Hover Effect ==
class _HoverEffect extends StatefulWidget {
  final Widget child;

  const _HoverEffect({required this.child});

  @override
  State<_HoverEffect> createState() => __HoverEffectState();
}

class __HoverEffectState extends State<_HoverEffect> {
  double _elevation = 4.0;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _elevation = 8.0),
      onExit: (_) => setState(() => _elevation = 4.0),
      child: Card(
        elevation: _elevation,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: widget.child,
      ),
    );
  }
}
