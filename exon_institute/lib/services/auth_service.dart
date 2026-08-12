class AuthService {
  // App එක ක්‍රියාත්මක වන කාලය පුරාවට මේ දත්ත මතකයේ පවතී
  static String? userId;
  static String? userEmail;
  static String? userName;

  // යූසර් ලොග් වූ පසු මෙම දත්ත සෙට් කිරීමට
  static void setUser(String id, String email, {String? name}) {
    userId = id;
    userEmail = email;
    userName = name;
  }

  // ලොග් අවුට් වීමේදී දත්ත මකා දැමීමට
  static void clear() {
    userId = null;
    userEmail = null;
    userName = null;
  }
}
