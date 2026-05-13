class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.avatarType,
    this.avatarValue,
    required this.circleIds,
  });

  final String uid;
  final String email;
  final String displayName;
  final String avatarType;
  final String? avatarValue;
  final List<String> circleIds;

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'avatarType': avatarType,
        'avatarValue': avatarValue,
        'circleIds': circleIds,
      };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        uid: map['uid'] as String,
        email: map['email'] as String,
        displayName: map['displayName'] as String,
        avatarType: map['avatarType'] as String? ?? 'icon',
        avatarValue: map['avatarValue'] as String?,
        circleIds: List<String>.from(map['circleIds'] as List? ?? const []),
      );
}
