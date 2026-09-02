class UserProfile {
  const UserProfile({
    required this.uid,
    this.email,
    required this.displayName,
    this.photoUrl,
    this.isAnonymous = false,
    this.createdAt,
    this.lastLoginAt,
  });

  final String uid;
  final String? email;
  final String displayName;
  final String? photoUrl;
  final bool isAnonymous;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'isAnonymous': isAnonymous,
    'createdAt': createdAt?.toIso8601String(),
    'lastLoginAt': lastLoginAt?.toIso8601String(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    uid: json['uid'] as String? ?? '',
    email: json['email'] as String?,
    displayName: json['displayName'] as String? ?? 'طالب علم',
    photoUrl: json['photoUrl'] as String?,
    isAnonymous: json['isAnonymous'] as bool? ?? false,
    createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
    lastLoginAt: json['lastLoginAt'] != null ? DateTime.tryParse(json['lastLoginAt'] as String) : null,
  );
}
