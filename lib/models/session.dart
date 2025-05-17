class Session {
  static String userType = ""; // "individual", "company", "office"
  static int userId = 0;

  static void setSession({required String type, required int id}) {
    userType = type;
    userId = id;
  }

  static void clearSession() {
    userType = "";
    userId = 0;
  }
}
