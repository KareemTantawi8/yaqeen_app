class EndPoints {
  static String baseUrl = "http://44.223.53.133:4000/api/";
  static String login = "user/login";
  static String signUp = "user/sign-up";
  static String forgetPassword = "user/forgot-password";
  static String resetFrogetPassword = "user/reset-forgot-password";
  static String resetPassword = "user/reset-password";
  // static String resendOtpForSignUp = 'user/resend-otp';
  static String activateUser = 'user/activate-user';
  static String resetForgetPasswordForOtp = 'user/reset-forgot-password';
  static String getUserProfile = 'user/profile';
  static String getGender = 'gender';
  static String getCountry = 'location/countries';
  static String getStates = 'location/states';
  static String getCities = 'location/cities';
  static String getCompanyId = "company-type";
  static String updateUser = 'user/info';
  static String uploadImage = 'user/upload';
  static String resendOtp = 'user/resend-otp';
  static String createProfileCompany = 'company';
  static String bus = 'bus';
  static String getId = 'company';
  static String getYear = 'year';
  static const String station = 'station';
  
  // Islamic content endpoints
  static String getSurahs = 'surahs';
  static String getAzkar = 'azkar';
  static String getIslamicEvents = 'islamic-events';
  static String getAllahNames = 'allah-names';
  
  // External API endpoints
  static String getAllahNamesExternal = 'https://api.aladhan.com/v1/asmaAlHusna';
}
