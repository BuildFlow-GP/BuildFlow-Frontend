// screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:get/get.dart'; // إذا كنتِ ستستخدمينه للانتقال

import '../../services/notifications_service.dart';
import '../../models/notifications_model.dart';
import '../../utils/constants.dart'; // أو api_config.dart

// استيراد صفحات التفاصيل والانتقال إليها
import '../ReadonlyProfiles/office_readonly_profile.dart';
import '../ReadonlyProfiles/company_readonly_profile.dart';
import '../ReadonlyProfiles/project_readonly_profile.dart';

// إضافة سيرفس المشروع
import '../../services/create/project_service.dart';

// شاشات سيتم الانتقال إليها بناءً على الإجراء (للمستخدم)
import '../design/no_permit_screen.dart'; // شاشة استكمال البيانات بعد موافقة المكتب
import '../design/choose_office.dart'; // شاشة اختيار مكتب آخر عند الرفض

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  final ProjectService _projectService = ProjectService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isFetchingMore = false;
  bool _isProcessingAction = false; // لمنع الضغط المتكرر
  final ScrollController _scrollController = ScrollController();

  // مجموعة لتخزين IDs الإشعارات التي تم التعامل معها (Approve/Reject)
  final Set<int> _processedNotificationIds = {};

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
        _processedNotificationIds.clear();
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
              _totalPages = 1;
            }
          } else if (isRefresh && response.notifications.isEmpty) {
            _currentPage = 1;
            _totalPages = 0;
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
      debugPrint("Error loading notifications: $e");
    }
  }

  Future<void> _handleMarkAsReadIconTap(NotificationModel notification) async {
    if (notification.isRead || _isProcessingAction) return;
    setState(() => _isProcessingAction = true);
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark as read: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessingAction = false);
    }
  }

  Future<void> _markAllAsRead() async {
    if (_isProcessingAction) return;
    setState(() => _isProcessingAction = true);
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
    } finally {
      if (mounted) setState(() => _isProcessingAction = false);
    }
  }

  Future<void> _markAsReadAndThen(
    NotificationModel notification,
    Future<void> Function() onReadCompleteActionAsync,
  ) async {
    if (_isProcessingAction) return;
    setState(() => _isProcessingAction = true);

    Future<void> executeActionAfterReadLogic() async {
      try {
        await onReadCompleteActionAsync();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Action failed: ${e.toString()}')),
          );
        }
        debugPrint("Error during onReadCompleteActionAsync: $e");
      } finally {
        if (mounted && _isProcessingAction) {
          setState(() => _isProcessingAction = false);
        }
      }
    }

    if (notification.isRead) {
      await executeActionAfterReadLogic();
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
        await executeActionAfterReadLogic();
      } else {
        if (mounted) setState(() => _isProcessingAction = false);
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
        setState(() => _isProcessingAction = false);
      }
    }
  }

  Future<void> _handleProjectRequestResponse(
    NotificationModel notification,
    String action,
  ) async {
    if (notification.targetEntityId == null ||
        notification.targetEntityType != 'project' ||
        _isProcessingAction) {
      return;
    }
    await _markAsReadAndThen(notification, () async {
      try {
        await _projectService.respondToProjectRequest(
          notification.targetEntityId!,
          action,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Project request has been ${action}ed successfully.',
              ),
            ),
          );
          setState(() {
            _processedNotificationIds.add(notification.id);
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to $action project request: ${e.toString()}',
              ),
            ),
          );
        }
        debugPrint("Error ${action}ing project request: $e");
      }
    });
  }

  Future<void> _performUserOrGeneralAction(
    NotificationModel notification,
  ) async {
    //  الدالة موجودة بهذا الاسم
    await _markAsReadAndThen(
      notification,
      () async => _proceedWithUserOrGeneralAction(notification),
    );
  }

  Future<void> _proceedWithUserOrGeneralAction(
    NotificationModel notification,
  ) async {
    // الدالة موجودة بهذا الاسم
    if (!mounted) return;
    if (notification.targetEntityId == null ||
        notification.targetEntityType == null) {
      debugPrint("Notification action: No target entity.");
      return;
    }
    Widget? targetScreen;
    String? routeDescription;

    switch (notification.notificationType) {
      case 'PROJECT_APPROVED_BY_OFFICE':
        // تأكدي أن NoPermitScreen تقبل projectId
        targetScreen = NoPermitScreen(projectId: notification.targetEntityId!);
        routeDescription =
            "Complete project (ID: ${notification.targetEntityId}) details";
        break;
      case 'PROJECT_REJECTED_BY_OFFICE':
        targetScreen = const ChooseOfficeScreen();
        routeDescription =
            "Choose another office for project (ID: ${notification.targetEntityId})";
        break;
      case 'OFFICE_UPLOADED_2D_DOCUMENT':
      case 'OFFICE_UPLOADED_3D_DOCUMENT':
        targetScreen = ProjectreadDetailsScreen(
          projectId: notification.targetEntityId!,
        );
        routeDescription =
            "View project (ID: ${notification.targetEntityId}) documents";
        break;
      default:
        debugPrint(
          "No specific general action defined for notification type: ${notification.notificationType}",
        );
        await _navigateToTargetEntity(notification, skipMarkAsRead: true);
        return;
    }

    debugPrint("Navigating user to: $routeDescription");
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => targetScreen!),
    );
  }

  Future<void> _navigateToTargetEntity(
    NotificationModel notification, {
    bool skipMarkAsRead = false,
  }) async {
    Future<void> navigateAction() async {
      if (!mounted) return;
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
          debugPrint(
            "Unknown target entity type for navigation: ${notification.targetEntityType}",
          );
      }
      if (targetScreen != null) {
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetScreen!),
        );
      }
    }

    if (skipMarkAsRead || notification.isRead) {
      await navigateAction();
    } else {
      await _markAsReadAndThen(notification, navigateAction);
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

    bool isNewProjectRequestForOffice =
        notification.notificationType == 'NEW_PROJECT_REQUEST' &&
        !_processedNotificationIds.contains(notification.id) &&
        notification.recipientType == 'office';
    bool isProjectResponseForUser =
        (notification.notificationType == 'PROJECT_APPROVED_BY_OFFICE' ||
            notification.notificationType == 'PROJECT_REJECTED_BY_OFFICE') &&
        notification.recipientType == 'individual';

    String? generalActionButtonText;
    IconData? generalActionButtonIcon;

    if (!isNewProjectRequestForOffice && !isProjectResponseForUser) {
      switch (notification.notificationType) {
        case 'OFFICE_UPLOADED_2D_DOCUMENT':
        case 'OFFICE_UPLOADED_3D_DOCUMENT':
          generalActionButtonText = 'View Project';
          generalActionButtonIcon = Icons.visibility_outlined;
          break;
      }
    }

    return Material(
      color:
          notification.isRead
              ? Theme.of(context).cardColor
              : Theme.of(
                context,
              ).primaryColorLight.withAlpha((0.3 * 255).round()),
      child: InkWell(
        onTap: () => _navigateToTargetEntity(notification),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                                ? Theme.of(context).textTheme.bodySmall?.color
                                    ?.withAlpha((0.7 * 255).round())
                                : Theme.of(
                                  context,
                                ).textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 13.5,
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
                    if (isNewProjectRequestForOffice)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(
                              Icons.check_circle_outline,
                              size: 16,
                            ),
                            label: const Text('Approve'),
                            onPressed:
                                _isProcessingAction
                                    ? null
                                    : () => _handleProjectRequestResponse(
                                      notification,
                                      'approve',
                                    ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.cancel_outlined, size: 16),
                            label: const Text('Reject'),
                            onPressed:
                                _isProcessingAction
                                    ? null
                                    : () => _handleProjectRequestResponse(
                                      notification,
                                      'reject',
                                    ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.red.shade400),
                              foregroundColor: Colors.red.shade700,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      )
                    else if (isProjectResponseForUser)
                      TextButton.icon(
                        icon: Icon(
                          notification.notificationType ==
                                  'PROJECT_APPROVED_BY_OFFICE'
                              ? Icons.edit_note_outlined
                              : Icons.find_replace_outlined,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        label: Text(
                          notification.notificationType ==
                                  'PROJECT_APPROVED_BY_OFFICE'
                              ? 'Complete Project Info'
                              : 'Choose Another Office',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        onPressed:
                            _isProcessingAction
                                ? null
                                : () => _performUserOrGeneralAction(
                                  notification,
                                ), //  الاسم الصحيح
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          minimumSize: const Size(0, 28),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      )
                    else if (generalActionButtonText != null)
                      TextButton.icon(
                        icon: Icon(
                          generalActionButtonIcon ?? Icons.arrow_forward_ios,
                          size: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        label: Text(
                          generalActionButtonText,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        onPressed:
                            _isProcessingAction
                                ? null
                                : () => _performUserOrGeneralAction(
                                  notification,
                                ), //  الاسم الصحيح
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          minimumSize: const Size(0, 28),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      )
                    else
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
              const SizedBox(width: 4.0),
              SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    notification.isRead
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color:
                        notification.isRead
                            ? Colors.green.shade600
                            : Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  tooltip: notification.isRead ? 'Read' : 'Mark as Read',
                  onPressed:
                      (notification.isRead || _isProcessingAction)
                          ? null
                          : () => _handleMarkAsReadIconTap(notification),
                ),
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
              onPressed: _isProcessingAction ? null : _markAllAsRead,
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
                _isLoading || _isFetchingMore || _isProcessingAction
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
          if (index >= _notifications.length) return const SizedBox.shrink();

          final notification = _notifications[index];
          return _buildNotificationItem(notification);
        },
        separatorBuilder:
            (context, index) => const Divider(
              height: 0,
              thickness: 0.5,
              indent: 70,
              endIndent: 16,
            ),
      ),
    );
  }
}
