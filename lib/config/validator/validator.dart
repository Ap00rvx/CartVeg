import 'package:email_validator/email_validator.dart';

class Validators {
  static bool validateEmail(String email) {
    return EmailValidator.validate(email); 
  }
}
