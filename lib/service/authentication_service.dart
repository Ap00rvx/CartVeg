import 'package:cart_veg/config/constant/constant.dart';
import 'package:cart_veg/model/verify_otp_model.dart';
import 'package:cart_veg/service/local_storage.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthenticationService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: BASE_URL,
    connectTimeout: Duration(seconds: 15),
    receiveTimeout: Duration(seconds: 15),
  ));

  late final User? _user;

  Future<Either<String, String>> sendOTPToEmail(String email) async {
    try {
      final response =
          await _dio.post("/user/authenticate", data: {"user_email": email});
      if (response.statusCode == 200) {
        return right("OTP sent to your email");
      } else {
        return left("Failed to send OTP");
      }
    } catch (err) {
      return left("Failed to send OTP");
    }
  }

  Future<Either<String, VerifyOtpResponse>> verifyOTP(
      String otp, String email) async {
    try {
      final response = await _dio
          .post("user/verify-otp", data: {"otp": otp, "email": email});
      if (response.statusCode == 200) {
        final json = response.data;
        return right(VerifyOtpResponse.fromJson(json));
      } else {
        return left("Failed to verify OTP");
      }
    } catch (err) {
      print(err);
      return left("Failed to verify OTP");
    }
  }

  Future<Either<String, User>> saveUserDetails(
      String name, String phone, String email) async {
    try {
      final token = await LocalStorageService().getToken();
      _dio.options.headers["Authorization"] = "Bearer $token";
      final response = await _dio.post("user/save", data: {
        "phone": phone,
        "name": name,
        "email": email.trim(),
      });
      if (response.statusCode == 200) {
        final json = response.data;
        return right(User.fromJson(json["data"]));
      } else {
        return left("Failed to save user details");
      }
    } on DioException catch (err) {
      print(err.response);
      return left("Failed to save user details");
    }
  }

  Future<Either<String, User>> getUserDetails() async {
    try {
      final token = await LocalStorageService().getToken();
      _dio.options.headers["Authorization"] = "Bearer $token";
      final response = await _dio.get("user/");
      print(response.data);
      if (response.statusCode == 200) {
        final json = response.data;
        _user = User.fromJson(json["user"]);
        return right(_user!);
      }

      return left("Failed to get user details");
    } catch (err) {
      print(err);
      return left("Failed to get user details");
    }
  }

  Future<bool> isTokenValid() async {
    try {
      final token = await LocalStorageService().getToken();
      print(token);
      if (token.isEmpty) {
        return false;
      }
      final isExpired = JwtDecoder.isExpired(token);
      if (isExpired) {
        return false;
      } else {
        return true;
      }
    } catch (err) {
      return false;
    }
  }

  User? get user => _user;
}
