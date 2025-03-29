import 'package:cart_veg/config/constant/constant.dart';
import 'package:cart_veg/model/verify_otp_model.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

class AuthenticationService {

  final Dio _dio =  Dio(
    BaseOptions(
      baseUrl: BASE_URL,
      connectTimeout: Duration(seconds: 15),
      receiveTimeout: Duration(seconds: 15),
    )
  );
  

  

  Future<Either<String,String>> sendOTPToEmail(String email) async{
    try{
      final response = await _dio.post("/user/authenticate",data: {
        "user_email": email
      });
      if(response.statusCode == 200){
        return right("OTP sent to your email");
      }else{
        return left("Failed to send OTP");
      }

    }catch(err){
      return left("Failed to send OTP");
    }
  }

  Future<Either<String, VerifyOtpResponse>> verifyOTP(String otp,String email ) async{
    try{
      final response = await _dio.post("/user/verify",data: {
        "otp": otp,
        "email": email
      });
      if(response.statusCode == 200){
        final json = response.data;
        return right(VerifyOtpResponse.fromJson(
          json
        ));
      }else{
        return left("Failed to verify OTP");
      }

    }catch(err){
      return left("Failed to verify OTP");
    }
  }

  




}