class AdminConfig {
  static const String adminEmail = "nastja.susilovic@gmail.com";

  static bool isAdminEmail(String email) {
    return email.toLowerCase() == adminEmail.toLowerCase();
  }
}
