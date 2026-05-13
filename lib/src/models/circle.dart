class Circle {
  const Circle({
    required this.id,
    required this.name,
    required this.type,
    required this.shareCode,
    required this.memberUids,
  });

  final String id;
  final String name;
  final String type;
  final String shareCode;
  final List<String> memberUids;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'shareCode': shareCode,
        'memberUids': memberUids,
      };
}
