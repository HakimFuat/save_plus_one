class User {
  final String id;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.createdAt,
    required this.updatedAt,
  }) {
    if (id.isEmpty) {
        throw ArgumentError('User ID cannot be empty');
    }
    if (email.isEmpty) {
        throw ArgumentError('User email cannot be empty');
    }
    if (displayName.isEmpty) {
        throw ArgumentError('User display name cannot be empty');
    }
  }
}