import '../utils/env_helper.dart';

class OtpConfig {
  static const String smtpHost = 'smtp.gmail.com';
  static const int smtpPort = 587;
  
  static String get smtpUsername => EnvHelper.get('SMTP_USERNAME');
  static String get smtpPassword => EnvHelper.get('SMTP_PASSWORD');
}
