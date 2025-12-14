import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/community.dart';
import '../../../core/services/community_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/notification_service.dart';

class ChatScreen extends StatefulWidget {
  final Friend friend;

  const ChatScreen({super.key, required this.friend});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _currentUserId;
  Timer? _pollingTimer;
  static const _pollInterval = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    // Get current user ID
    final authService = context.read<AuthService>();
    _currentUserId = authService.user?.id;
    
    // Load messages
    await _loadMessages();
    
    // Mark messages as read
    _markMessagesAsRead();
    
    // Start polling for new messages
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(_pollInterval, (_) => _pollMessages());
  }

  Future<void> _pollMessages() async {
    if (!mounted) return;
    
    try {
      final communityService = context.read<CommunityService>();
      final newMessages = await communityService.loadMessages(widget.friend.id);
      
      if (!mounted) return;
      
      // Check if there are new messages
      if (newMessages.length > _messages.length) {
        final hadMessages = _messages.isNotEmpty;
        setState(() {
          _messages = newMessages;
        });
        
        // Only scroll to bottom if we already had messages (new message arrived)
        if (hadMessages) {
          _scrollToBottom();
          _markMessagesAsRead();
        }
      } else if (newMessages.length == _messages.length && newMessages.isNotEmpty) {
        // Check if last message is different (might be read status update)
        final lastNew = newMessages.last;
        final lastOld = _messages.last;
        if (lastNew.id != lastOld.id || lastNew.isRead != lastOld.isRead) {
          setState(() {
            _messages = newMessages;
          });
        }
      }
    } catch (e) {
      debugPrint('Polling error: $e');
    }
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    
    try {
      final communityService = context.read<CommunityService>();
      final messages = await communityService.loadMessages(widget.friend.id);
      
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      
      // Scroll to bottom after loading
      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading messages: $e');
    }
  }

  Future<void> _markMessagesAsRead() async {
    try {
      final communityService = context.read<CommunityService>();
      await communityService.markMessagesAsRead(widget.friend.id);
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      final communityService = context.read<CommunityService>();
      final sentMessage = await communityService.sendMessage(
        receiverId: widget.friend.id,
        content: text,
      );

      if (sentMessage != null) {
        setState(() {
          _messages.add(sentMessage);
          _isSending = false;
        });
        _scrollToBottom();
      } else {
        // Show error
        if (mounted) {
          context.read<NotificationService>().showError(
            communityService.error ?? 'Failed to send message',
          );
        }
        setState(() => _isSending = false);
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      if (mounted) {
        context.read<NotificationService>().showError('Failed to send message');
      }
      setState(() => _isSending = false);
    }
  }

  bool _isMyMessage(ChatMessage message) {
    return message.senderId == _currentUserId;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: _buildAppBar(isDark),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: _isLoading
                ? _buildLoadingState(isDark)
                : _messages.isEmpty
                    ? _buildEmptyState(isDark)
                    : _buildMessagesList(isDark),
          ),

          // Input Area
          _buildInputArea(isDark),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ),
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: widget.friend.avatarUrl != null
                    ? NetworkImage(widget.friend.avatarUrl!)
                    : null,
                child: widget.friend.avatarUrl == null
                    ? Text(
                        widget.friend.name.isNotEmpty
                            ? widget.friend.name[0].toUpperCase()
                            : 'U',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              if (widget.friend.isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.cardDark : AppColors.cardLight,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.friend.name,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.friend.isOnline ? 'Online' : 'Offline',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: widget.friend.isOnline
                        ? AppColors.success
                        : (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(
            Iconsax.more,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          onSelected: (value) {
            switch (value) {
              case 'refresh':
                _loadMessages();
                break;
              case 'clear':
                _showClearChatDialog();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  Icon(Iconsax.refresh, size: 20),
                  SizedBox(width: 12),
                  Text('Refresh'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Iconsax.trash, size: 20, color: AppColors.error),
                  SizedBox(width: 12),
                  Text('Clear Chat', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showClearChatDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        title: Text(
          'Clear Chat',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          'Are you sure you want to clear all messages with ${widget.friend.name}? This action cannot be undone.',
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _messages.clear());
              context.read<NotificationService>().showSuccess('Chat cleared');
            },
            child: const Text('Clear', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Loading messages...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.message,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No messages yet',
            style: AppTextStyles.titleLarge.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start the conversation with ${widget.friend.name}!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildMessagesList(bool isDark) {
    return RefreshIndicator(
      onRefresh: _loadMessages,
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          final isMe = _isMyMessage(message);
          final showDate = index == 0 ||
              !_isSameDay(message.sentAt, _messages[index - 1].sentAt);

          return Column(
            children: [
              if (showDate)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? AppColors.surfaceDark 
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatDate(message.sentAt),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                    ),
                  ),
                ),
              _MessageBubble(
                message: message,
                isMe: isMe,
                friendName: widget.friend.name,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Attachment button (for future use)
            IconButton(
              onPressed: () {
                context.read<NotificationService>().showInfo('Attachments coming soon!');
              },
              icon: const Icon(Iconsax.attach_circle, color: AppColors.primary),
            ),
            
            // Message input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  maxLines: 4,
                  minLines: 1,
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Send button
            GestureDetector(
              onTap: _isSending ? null : _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isSending 
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: _isSending
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Iconsax.send_1,
                        color: Colors.white,
                        size: 22,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) {
      return 'Today';
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final String friendName;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.friendName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: isMe ? 60 : 0,
          right: isMe ? 0 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.primary
              : (isDark ? AppColors.cardDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show simulation attachment if present
            if (message.simulationId != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isMe 
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.cpu,
                      size: 16,
                      color: isMe ? Colors.white : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Simulation Shared',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isMe ? Colors.white : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Message content
            Text(
              message.content,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isMe
                    ? Colors.white
                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Timestamp and read status
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.sentAt),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isMe
                        ? Colors.white.withValues(alpha: 0.7)
                        : (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: message.isRead 
                        ? Colors.lightBlueAccent
                        : Colors.white.withValues(alpha: 0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideX(begin: isMe ? 0.1 : -0.1);
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
