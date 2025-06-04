// screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/notifications_service.dart'; // تأكدي أن اسم الملف services/notification_service.dart
import '../models/notifications_model.dart'; // تأكدي أن اسم الملف models/notification_model.dart
import '../utils/constants.dart'; // أو api_config.dart لـ Constants.baseUrl

// استيراد صفحات التفاصيل والانتقال إليها
import 'ReadonlyProfiles/office_readonly_profile.dart';
import 'ReadonlyProfiles/company_readonly_profile.dart';
import 'ReadonlyProfiles/project_readonly_profile.dart';
import 'Design/type_of_project.dart';
// import 'projects/fill_project_details_screen.dart'; // ستحتاجين لهذه الشاشة

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isFetchingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadNotifications(isRefresh: true);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          _currentPage < _totalPages &&
          !_isLoading &&
          !_isFetchingMore) {
        _loadNotifications();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications({bool isRefresh = false}) async {
    if (!mounted) return;
    if (_isFetchingMore && !isRefresh) return;

    setState(() {
      if (isRefresh) {
        _isLoading = true;
        _error = null;
        _notifications = [];
        _currentPage = 1;
        _totalPages = 1;
      } else {
        _isFetchingMore = true;
      }
    });

    try {
      // الـ offset في API يبدأ من 0 للصفحة الأولى
      final response = await _notificationService.getMyNotifications(
        offset:
            (isRefresh ? 0 : (_currentPage - 1)) *
            20, // إذا كان _currentPage يبدأ من 1 للـ UI
        limit: 20,
      );
      if (mounted) {
        setState(() {
          if (isRefresh) {
            _notifications = response.notifications;
          } else {
            _notifications.addAll(response.notifications);
          }
          _totalPages = response.totalPages;
          // تحديث الصفحة الحالية للـ UI
          // إذا كان الـ API يرجع currentPage (يبدأ من 1)، استخدميه
          // _currentPage = response.currentPage;
          // أو إذا كنا نزيدها يدوياً:
          if (!isRefresh && response.notifications.isNotEmpty) {
            _currentPage++;
          } else if (isRefresh && response.notifications.isNotEmpty) {
            _currentPage = 1; // أو response.currentPage
          } else if (isRefresh && response.notifications.isEmpty) {
            _currentPage = 1; // لا تزال الصفحة الأولى حتى لو فارغة
          }

          _isLoading = false;
          _isFetchingMore = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _isFetchingMore = false;
        });
      }
      print("Error loading notifications: $e");
    }
  }

  // ✅ تعديل: هذه الدالة الآن فقط تعلم كمقروء وتحدث الـ UI
  Future<void> _toggleReadStatusOnly(NotificationModel notification) async {
    if (notification.isRead) {
      print("Notification is already read. No UI change from this button.");
      // إذا أردتِ السماح بـ "Mark as Unread" لاحقاً، ستحتاجين منطقاً هنا والـ backend
      return;
    }

    try {
      // استدعاء السيرفس لتعليم الإشعار كمقروء
      final updatedNotification = await _notificationService
          .markNotificationAsRead(notification.id);
      if (updatedNotification != null && mounted) {
        setState(() {
          // تحديث الإشعار في القائمة المحلية
          final index = _notifications.indexWhere(
            (n) => n.id == notification.id,
          );
          if (index != -1) {
            _notifications[index] = updatedNotification;
          }
        });
        // لا يوجد انتقال هنا
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark as read: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    // ... (نفس الكود)
    try {
      final count = await _notificationService.markAllNotificationsAsRead();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$count notifications marked as read.')),
        );
        _loadNotifications(isRefresh: true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark all as read: ${e.toString()}'),
          ),
        );
      }
    }
  }

  // ✅ تعديل: هذه الدالة ستستخدم عند الضغط على الإجراء أو على الإشعار نفسه (إذا لم يكن مقروءاً)
  Future<void> _markAsReadAndThen(
    NotificationModel notification,
    VoidCallback onReadCompleteAction,
  ) async {
    if (notification.isRead) {
      onReadCompleteAction(); // إذا كان مقروءاً بالفعل، نفذ الإجراء مباشرة
      return;
    }
    try {
      final updatedNotification = await _notificationService
          .markNotificationAsRead(notification.id);
      if (updatedNotification != null && mounted) {
        setState(() {
          final index = _notifications.indexWhere(
            (n) => n.id == notification.id,
          );
          if (index != -1) {
            _notifications[index] = updatedNotification;
          }
        });
        onReadCompleteAction(); // نفذ الإجراء بعد التحديث الناجح
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to mark as read before action: ${e.toString()}',
            ),
          ),
        );
      }
    }
  }

  void _performNotificationAction(NotificationModel notification) {
    _markAsReadAndThen(notification, () => _proceedWithAction(notification));
  }

  void _proceedWithAction(NotificationModel notification) {
    // ... (نفس كود _proceedWithAction من الرد السابق)
    if (notification.targetEntityId == null ||
        notification.targetEntityType == null) {
      print("Notification action: No target entity.");
      return;
    }
    switch (notification.notificationType) {
      case 'NEW_PROJECT_REQUEST':
        if (notification.targetEntityType == 'project' && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ProjectreadDetailsScreen(
                    projectId: notification.targetEntityId!,
                  ),
            ),
          );
        }
        break;
      case 'PROJECT_APPROVED_BY_OFFICE':
        if (notification.targetEntityType == 'project' && mounted) {
          // Navigator.push(context, MaterialPageRoute(builder: (context) => FillProjectDetailsScreen(projectId: notification.targetEntityId!)));
          print(
            "TODO: Navigate to FillProjectDetailsScreen for project ${notification.targetEntityId}",
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Navigate to complete project ID: ${notification.targetEntityId}",
              ),
            ),
          );
        }
        break;
      case 'PROJECT_REJECTED_BY_OFFICE':
        if (mounted) {
          // Navigator.push(context, MaterialPageRoute(builder: (context) => const TypeOfProjectPage()));
          print(
            "TODO: Navigate to choose another office or see rejection reason for project ${notification.targetEntityId}",
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Project ID: ${notification.targetEntityId} was rejected. Choose another office.",
              ),
            ),
          );
        }
        break;
      case 'OFFICE_UPLOADED_2D_DOCUMENT':
      case 'OFFICE_UPLOADED_3D_DOCUMENT':
        if (notification.targetEntityType == 'project' && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ProjectreadDetailsScreen(
                    projectId: notification.targetEntityId!,
                  ),
            ),
          );
        }
        break;
      default:
        print(
          "No specific action defined for notification type: ${notification.notificationType}",
        );
        _navigateToTargetEntity(notification); // الانتقال الافتراضي
    }
  }

  void _navigateToTargetEntity(NotificationModel notification) {
    _markAsReadAndThen(notification, () {
      // ✅ تعليم كمقروء قبل الانتقال
      if (notification.targetEntityId == null ||
          notification.targetEntityType == null)
        return;
      Widget? targetScreen;
      switch (notification.targetEntityType!.toLowerCase()) {
        case 'project':
          targetScreen = ProjectreadDetailsScreen(
            projectId: notification.targetEntityId!,
          );
          break;
        case 'office_profile':
        case 'office':
          targetScreen = OfficerProfileScreen(
            officeId: notification.targetEntityId!,
          );
          break;
        case 'company_profile':
        case 'company':
          targetScreen = CompanyrProfileScreen(
            companyId: notification.targetEntityId!,
          );
          break;
        default:
          print(
            "Unknown target entity type for navigation: ${notification.targetEntityType}",
          );
      }
      if (targetScreen != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetScreen!),
        );
      }
    });
  }

  String _formatTimeAgo(DateTime dateTime) {
    // ... (نفس الكود)
    final now = DateTime.now();
    final difference = now.difference(dateTime.toLocal());

    if (difference.inSeconds < 5) return 'just now';
    if (difference.inSeconds < 60) return '${difference.inSeconds}s ago';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return DateFormat('dd MMM').format(dateTime.toLocal());
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    final timeAgo = _formatTimeAgo(notification.createdAt);

    ImageProvider? actorImageProvider;
    IconData actorDefaultIcon = Icons.person_outline;

    if (notification.actor?.profileImage != null &&
        notification.actor!.profileImage!.isNotEmpty) {
      actorImageProvider = NetworkImage(
        notification.actor!.profileImage!.startsWith('http')
            ? notification.actor!.profileImage!
            : '${Constants.baseUrl}/${notification.actor!.profileImage}', // استخدام Constants.baseUrl
      );
    } else if (notification.actor != null) {
      switch (notification.actor!.type.toLowerCase()) {
        case 'office':
          actorDefaultIcon = Icons.maps_home_work_outlined;
          break;
        case 'company':
          actorDefaultIcon = Icons.apartment_outlined;
          break;
        case 'individual':
        default:
          actorDefaultIcon = Icons.person_outline;
          break;
      }
    }

    String? actionButtonText;
    IconData? actionButtonIcon;

    switch (notification.notificationType) {
      case 'PROJECT_APPROVED_BY_OFFICE':
        actionButtonText = 'Complete Info'; // نص أقصر
        actionButtonIcon = Icons.edit_note_outlined;
        break;
      case 'PROJECT_REJECTED_BY_OFFICE':
        actionButtonText = 'Find Office'; // نص أقصر
        actionButtonIcon = Icons.search_outlined;
        break;
      case 'OFFICE_UPLOADED_2D_DOCUMENT':
      case 'OFFICE_UPLOADED_3D_DOCUMENT':
      case 'NEW_PROJECT_REQUEST': // للمكتب، يمكن أن يكون الإجراء "View Request"
        actionButtonText = 'View Details'; // نص عام
        actionButtonIcon = Icons.visibility_outlined;
        break;
    }

    return Material(
      color:
          notification.isRead
              ? Theme.of(context)
                  .cardColor // أو canvasColor إذا كان الكرت له لون مختلف
              : Theme.of(context).primaryColor.withOpacity(
                0.08,
              ), // لون أغمق قليلاً للإشعار غير المقروء
      child: InkWell(
        onTap:
            () => _navigateToTargetEntity(
              notification,
            ), // الضغط على الإشعار كله ينقله ويعلمه كمقروء
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: actorImageProvider,
                backgroundColor: Colors.grey[300],
                onBackgroundImageError:
                    actorImageProvider != null ? (_, __) {} : null,
                child:
                    actorImageProvider == null
                        ? Icon(
                          actorDefaultIcon,
                          size: 20,
                          color: Colors.grey[700],
                        )
                        : null,
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.actor?.name ?? 'System Notification',
                      style: TextStyle(
                        fontWeight: FontWeight.w600, // خط أعرض قليلاً
                        fontSize: 15,
                        color:
                            notification.isRead
                                ? Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color // لون أفتح للمقروء
                                : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            notification.isRead
                                ? Colors.grey[700] // لون أفتح للمقروء
                                : Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (actionButtonText != null)
                          TextButton.icon(
                            icon: Icon(
                              actionButtonIcon ?? Icons.arrow_forward_ios,
                              size: 16,
                            ),
                            label: Text(
                              actionButtonText,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onPressed:
                                () => _performNotificationAction(notification),
                            style: TextButton.styleFrom(
                              // primary: Theme.of(context).colorScheme.secondary, // لون مميز للزر
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              minimumSize: const Size(0, 28), // حجم أصغر للزر
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              // ✅ كبسة "تعليم كمقروء" فقط
              Column(
                mainAxisAlignment: MainAxisAlignment.center, // لتوسيط الأيقونة
                children: [
                  IconButton(
                    icon: Icon(
                      notification.isRead
                          ? Icons.check_circle_outline
                          : Icons.radio_button_unchecked_outlined,
                      color:
                          notification.isRead
                              ? Colors.green
                              : Theme.of(context).colorScheme.secondary,
                      size: 22,
                    ),
                    tooltip: notification.isRead ? 'Read' : 'Mark as Read',
                    // إذا كان مقروءاً، لا يوجد فعل عند الضغط على هذه الأيقونة
                    // أو يمكنكِ إضافة خيار "Mark as Unread" إذا كان الـ backend يدعمه
                    onPressed:
                        notification.isRead
                            ? null
                            : () => _toggleReadStatusOnly(notification),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (نفس الكود)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_notifications.any((n) => !n.isRead) &&
              !_isLoading &&
              !_isFetchingMore)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark All Read',
                style: TextStyle(color: Colors.white),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed:
                _isLoading || _isFetchingMore
                    ? null
                    : () => _loadNotifications(isRefresh: true),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // ... (نفس الكود)
    if (_isLoading && _notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _notifications.isEmpty) {
      return Center(/* ... */);
    }
    if (_notifications.isEmpty && !_isLoading) {
      return Center(/* ... */);
    }
    return RefreshIndicator(
      onRefresh: () => _loadNotifications(isRefresh: true),
      child: ListView.separated(
        controller: _scrollController,
        itemCount: _notifications.length + (_isFetchingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _notifications.length && _isFetchingMore) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
            );
          }
          if (index >= _notifications.length) return const SizedBox.shrink();

          final notification = _notifications[index];
          return _buildNotificationItem(notification);
        },
        separatorBuilder:
            (context, index) => const Divider(
              height: 0,
              thickness: 0.5,
              indent: 16,
              endIndent: 16,
            ),
      ),
    );
  }
}
