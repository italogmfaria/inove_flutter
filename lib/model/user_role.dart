enum UserRole {
  STUDENT;

  String toJson() {
    return name;
  }

  static UserRole fromJson(String value) {
    return UserRole.STUDENT;
  }
}
