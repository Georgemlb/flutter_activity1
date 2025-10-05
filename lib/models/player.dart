class Player {
  String id;        // simple string id
  String nickname;
  String fullName;
  String contact;
  String email;
  String address;
  String remarks;
  int levelStart;   // 0..20
  int levelEnd;     // 0..20

  Player({
    required this.id,
    required this.nickname,
    required this.fullName,
    required this.contact,
    required this.email,
    required this.address,
    required this.remarks,
    required this.levelStart,
    required this.levelEnd,
  });
}
