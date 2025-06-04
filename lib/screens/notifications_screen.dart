// screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/notifications_service.dart'; // تأكدي من أن اسم الملف services/notification_service.dart
import '../models/notifications_model.dart'; // تأكدي أن اسم الملف models/notification_model.dart
import '../utils/constants.dart'; // أو api_config.dart لـ Constants.baseUrl

// استيراد صفحات التفاصيل والانتقال إليها
import 'ReadonlyProfiles/office_readonly_profile.dart';
import 'ReadonlyProfiles/company_readonly_profile.dart';
import 'ReadonlyProfiles/project_readonly_profile.dart';
// مثال لصفحات أخرى قد تحتاجيها
// import 'Design/type_of_project.dart';
// import 'projects/fill_project_details_screen.dart';

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
      final response = await _notificationService.getMyNotifications(
        offset: (isRefresh ? 0 : (_currentPage - 1)) * 20,
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
          if (!isRefresh && response.notifications.isNotEmpty) {
            _currentPage++;
          } else if (isRefresh && response.notifications.isNotEmpty) {
            _currentPage = 1;
            if (response.totalPages == 0 && response.totalItems > 0) {
              // حالة خاصة إذا كان API يرجع totalPages=0 لصفحة واحدة
              _totalPages = 1;
            }
          } else if (isRefresh && response.notifications.isEmpty) {
            _currentPage = 1;
            _totalPages = 0; // أو 1 إذا كان الـ API يرجع ذلك
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

  // ✅ الدالة التي يتم استدعاؤها عند الضغط على أيقونة "Mark as Read"
  Future<void> _handleMarkAsReadIconTap(NotificationModel notification) async {
    if (notification.isRead) {
      print("Notification is already read. Icon tap does nothing further.");
      return; // لا تفعل شيئاً إذا كانت مقروءة بالفعل
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
        // لا يوجد انتقال هنا، فقط تحديث الـ UI
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

  Future<void> _markAsReadAndThen(
    NotificationModel notification,
    VoidCallback onReadCompleteAction,
  ) async {
    if (notification.isRead) {
      onReadCompleteAction();
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
        onReadCompleteAction();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  void _performNotificationAction(NotificationModel notification) {
    _markAsReadAndThen(notification, () => _proceedWithAction(notification));
  }

  void _proceedWithAction(NotificationModel notification) {
    if (notification.targetEntityId == null ||
        notification.targetEntityType == null) {
      print("Notification action: No target entity.");
      return;
    }
    Widget? targetScreen;
    switch (notification.notificationType) {
      case 'NEW_PROJECT_REQUEST':
        targetScreen = ProjectreadDetailsScreen(
          projectId: notification.targetEntityId!,
        );
        break;
      case 'PROJECT_APPROVED_BY_OFFICE':
        // targetScreen = FillProjectDetailsScreen(projectId: notification.targetEntityId!);
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
        return; // لا تنتقل إذا لم تكن الشاشة جاهزة
      case 'PROJECT_REJECTED_BY_OFFICE':
        // targetScreen = const TypeOfProjectPage(); // أو شاشة تعرض سبب الرفض
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
        return; // لا تنتقل إذا لم تكن الشاشة جاهزة
      case 'OFFICE_UPLOADED_2D_DOCUMENT':
      case 'OFFICE_UPLOADED_3D_DOCUMENT':
        targetScreen = ProjectreadDetailsScreen(
          projectId: notification.targetEntityId!,
        );
        break;
      default:
        print(
          "No specific action defined for notification type: ${notification.notificationType}",
        );
        _navigateToTargetEntity(
          notification,
          skipMarkAsRead: true,
        ); // تم تعليمه كمقروء بالفعل
        return;
    }
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetScreen!),
      );
    }
  }

  void _navigateToTargetEntity(
    NotificationModel notification, {
    bool skipMarkAsRead = false,
  }) {
    navigateAction() {
      if (notification.targetEntityId == null ||
          notification.targetEntityType == null) {
        return;
      }
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
    }

    if (skipMarkAsRead) {
      navigateAction();
    } else {
      _markAsReadAndThen(notification, navigateAction);
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
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
            : '${Constants.baseUrl}/${notification.actor!.profileImage}',
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
    bool isProjectRequestForOffice =
        notification.notificationType == 'NEW_PROJECT_REQUEST'; // للمكتب
    // يمكنك إضافة متغير مماثل إذا كان الإشعار للمستخدم وهو ينتظر الموافقة

    if (!isProjectRequestForOffice) {
      // إذا لم يكن طلب مشروع جديد للمكتب، أظهري زر الإجراء العام
      switch (notification.notificationType) {
        case 'PROJECT_APPROVED_BY_OFFICE':
          actionButtonText = 'Complete Info';
          actionButtonIcon = Icons.edit_note_outlined;
          break;
        case 'PROJECT_REJECTED_BY_OFFICE':
          actionButtonText = 'Find Office';
          actionButtonIcon = Icons.search_outlined;
          break;
        case 'OFFICE_UPLOADED_2D_DOCUMENT':
        case 'OFFICE_UPLOADED_3D_DOCUMENT':
          actionButtonText = 'View Project';
          actionButtonIcon = Icons.visibility_outlined;
          break;
      }
    }

    return Material(
      color:
          notification.isRead
              ? Theme.of(context).cardColor
              : Theme.of(context).highlightColor, // لون أفتح قليلاً للتمييز
      child: InkWell(
        onTap: () => _navigateToTargetEntity(notification),
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
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color:
                            notification.isRead
                                ? Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color?.withOpacity(0.7)
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
                                ? Colors.grey[700]
                                : Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight:
                            notification.isRead
                                ? FontWeight.normal
                                : FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // عرض أزرار Approve/Reject أو زر الإجراء العام أو الوقت
                    if (isProjectRequestForOffice)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextButton.icon(
                            icon: const Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                              size: 18,
                            ),
                            label: const Text(
                              'Approve',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              _markAsReadAndThen(notification, () {
                                // استدعاء API الموافقة هنا
                                // مثال: ProjectService().respondToProjectRequest(notification.targetEntityId!, 'approve');
                                // ثم _loadNotifications(isRefresh: true);
                                print(
                                  "TODO: Implement Approve action for project ${notification.targetEntityId}",
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Approve action pressed (not implemented)",
                                    ),
                                  ),
                                );
                              });
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            icon: const Icon(
                              Icons.cancel_outlined,
                              color: Colors.red,
                              size: 18,
                            ),
                            label: const Text(
                              'Reject',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              _markAsReadAndThen(notification, () {
                                // استدعاء API الرفض هنا
                                // مثال: ProjectService().respondToProjectRequest(notification.targetEntityId!, 'reject');
                                // ثم _loadNotifications(isRefresh: true);
                                print(
                                  "TODO: Implement Reject action for project ${notification.targetEntityId}",
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Reject action pressed (not implemented)",
                                    ),
                                  ),
                                );
                              });
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                            ),
                          ),
                        ],
                      )
                    else if (actionButtonText !=
                        null) // زر الإجراء العام لأنواع أخرى
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey[600],
                            ),
                          ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              minimumSize: const Size(0, 28),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      )
                    else // إذا لم يكن هناك إجراء خاص، اعرضي الوقت فقط
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      notification.isRead
                          ? Icons.check_circle
                          : Icons.circle_outlined, // أيقونات مختلفة
                      color:
                          notification.isRead
                              ? Colors.green.shade600
                              : Theme.of(context).colorScheme.primary,
                      size: 22,
                    ),
                    tooltip: notification.isRead ? 'Read' : 'Mark as Read',
                    onPressed:
                        notification.isRead
                            ? null
                            : () => _handleMarkAsReadIconTap(notification),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_notifications.any((n) => !n.isRead) &&
              !_isLoading &&
              !_isFetchingMore)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark All Read',
                style: TextStyle(
                  color:
                      Theme.of(context).appBarTheme.foregroundColor ??
                      Colors.white,
                ),
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
    if (_isLoading && _notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red[700], size: 50),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[700], fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: () => _loadNotifications(isRefresh: true),
              ),
            ],
          ),
        ),
      );
    }
    if (_notifications.isEmpty && !_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_off_outlined,
                color: Colors.grey[600],
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'You have no notifications yet.',
                style: TextStyle(fontSize: 18.0, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
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
          if (index >= _notifications.length)
            return const SizedBox.shrink(); // Safety check

          final notification = _notifications[index];
          return _buildNotificationItem(notification);
        },
        separatorBuilder:
            (context, index) => const Divider(
              height: 0,
              thickness: 0.5,
              indent: 70,
              endIndent: 16,
            ), // تعديل الفاصل ليبدأ بعد الصورة
      ),
    );
  }
}

// الدالة _navigateToTarget التي كانت في نهاية الملف السابق ليست جزءاً من الكلاس
// وتم دمج منطقها داخل _navigateToTargetEntity.
// إذا كنتِ تستخدمينها في مكان آخر، يجب نقلها أو إعادة تعريفها.
