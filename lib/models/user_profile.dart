class UserProfile {
  final String uid;
  final String email;
  final String? displayName;
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime? lastSeen;
  final List<String>? blockedUsers;

  UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    this.fcmToken,
    required this.createdAt,
    this.lastSeen,
    this.blockedUsers,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'fcmToken': fcmToken,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastSeen': lastSeen?.millisecondsSinceEpoch,
      'blockedUsers': blockedUsers,
    };
  }

  static UserProfile fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'],
      email: map['email'],
      displayName: map['displayName'],
      fcmToken: map['fcmToken'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      lastSeen: map['lastSeen'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['lastSeen'])
          : null,
      blockedUsers: map['blockedUsers'] != null 
          ? List<String>.from(map['blockedUsers'])
          : null,
    );
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? fcmToken,
    DateTime? createdAt,
    DateTime? lastSeen,
    List<String>? blockedUsers,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
      blockedUsers: blockedUsers ?? this.blockedUsers,
    );
  }
}