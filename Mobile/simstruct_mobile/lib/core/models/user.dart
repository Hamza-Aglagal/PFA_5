/// User Role Enum
enum UserRole {
  user,
  pro,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.user:
        return 'Free';
      case UserRole.pro:
        return 'Pro';
      case UserRole.admin:
        return 'Admin';
    }
  }
}

/// Subscription Plan
enum SubscriptionPlan {
  free,
  pro,
  enterprise;

  String get displayName {
    switch (this) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.pro:
        return 'Pro';
      case SubscriptionPlan.enterprise:
        return 'Enterprise';
    }
  }

  int get simulationsLimit {
    switch (this) {
      case SubscriptionPlan.free:
        return 10;
      case SubscriptionPlan.pro:
        return 50;
      case SubscriptionPlan.enterprise:
        return -1; // Unlimited
    }
  }

  double get storageLimit {
    switch (this) {
      case SubscriptionPlan.free:
        return 1.0; // 1 GB
      case SubscriptionPlan.pro:
        return 5.0; // 5 GB
      case SubscriptionPlan.enterprise:
        return 50.0; // 50 GB
    }
  }
}

/// Usage Statistics
class UsageStats {
  final int totalSimulations;
  final int monthlySimulations;
  final int sharedSimulations;
  final int completedSimulations;
  final int failedSimulations;
  final double storageUsed;
  final DateTime? lastSimulationAt;

  const UsageStats({
    this.totalSimulations = 0,
    this.monthlySimulations = 0,
    this.sharedSimulations = 0,
    this.completedSimulations = 0,
    this.failedSimulations = 0,
    this.storageUsed = 0,
    this.lastSimulationAt,
  });

  factory UsageStats.fromJson(Map<String, dynamic> json) {
    return UsageStats(
      totalSimulations: json['totalSimulations'] as int? ?? 0,
      monthlySimulations: json['monthlySimulations'] as int? ?? 0,
      sharedSimulations: json['sharedSimulations'] as int? ?? 0,
      completedSimulations: json['completedSimulations'] as int? ?? 0,
      failedSimulations: json['failedSimulations'] as int? ?? 0,
      storageUsed: (json['storageUsed'] as num?)?.toDouble() ?? 0,
      lastSimulationAt: json['lastSimulationAt'] != null
          ? DateTime.parse(json['lastSimulationAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSimulations': totalSimulations,
      'monthlySimulations': monthlySimulations,
      'sharedSimulations': sharedSimulations,
      'completedSimulations': completedSimulations,
      'failedSimulations': failedSimulations,
      'storageUsed': storageUsed,
      'lastSimulationAt': lastSimulationAt?.toIso8601String(),
    };
  }
}

/// User Profile
class UserProfile {
  final String? avatarUrl;
  final String? phone;
  final String? company;
  final String? jobTitle;
  final String? bio;
  final UsageStats stats;

  const UserProfile({
    this.avatarUrl,
    this.phone,
    this.company,
    this.jobTitle,
    this.bio,
    this.stats = const UsageStats(),
  });

  UserProfile copyWith({
    String? avatarUrl,
    String? phone,
    String? company,
    String? jobTitle,
    String? bio,
    UsageStats? stats,
  }) {
    return UserProfile(
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      jobTitle: jobTitle ?? this.jobTitle,
      bio: bio ?? this.bio,
      stats: stats ?? this.stats,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      avatarUrl: json['avatarUrl'] as String?,
      phone: json['phone'] as String?,
      company: json['company'] as String?,
      jobTitle: json['jobTitle'] as String?,
      bio: json['bio'] as String?,
      stats: json['stats'] != null
          ? UsageStats.fromJson(json['stats'] as Map<String, dynamic>)
          : const UsageStats(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avatarUrl': avatarUrl,
      'phone': phone,
      'company': company,
      'jobTitle': jobTitle,
      'bio': bio,
      'stats': stats.toJson(),
    };
  }
}

/// User Model
class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final SubscriptionPlan subscriptionPlan;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserProfile profile;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.role = UserRole.user,
    this.subscriptionPlan = SubscriptionPlan.free,
    this.emailVerified = false,
    required this.createdAt,
    required this.updatedAt,
    this.profile = const UserProfile(),
  });

  /// Get user initials (e.g., "JD" for "John Doe")
  String get initials {
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  /// Get first name
  String get firstName {
    final parts = name.trim().split(' ');
    return parts.isNotEmpty ? parts[0] : name;
  }

  /// Get avatar URL from profile
  String? get avatarUrl => profile.avatarUrl;

  /// Alias for emailVerified
  bool get isEmailVerified => emailVerified;

  /// Copy with method
  User copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    SubscriptionPlan? subscriptionPlan,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserProfile? profile,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profile: profile ?? this.profile,
    );
  }

  /// From JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.user,
      ),
      subscriptionPlan: SubscriptionPlan.values.firstWhere(
        (e) => e.name == json['subscriptionPlan'],
        orElse: () => SubscriptionPlan.free,
      ),
      emailVerified: json['emailVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      profile: json['profile'] != null
          ? UserProfile.fromJson(json['profile'] as Map<String, dynamic>)
          : const UserProfile(),
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'subscriptionPlan': subscriptionPlan.name,
      'emailVerified': emailVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'profile': profile.toJson(),
    };
  }
}
