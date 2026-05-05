import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../../../../core/constants/api_constants.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<String> forgotPassword(String email);
  Future<String> resetPassword(String email, String token, String newPassword);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw response.data['message'] ?? 'Gagal login';
      }
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? e.response?.data['error'] ?? 'Gagal login';
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<String> forgotPassword(String email) async {
    try {
      final response = await dio.post('/auth/forgot-password', data: {
        'email': email,
      });
      return response.data['message'] ?? 'Email pemulihan kata sandi telah dikirim.';
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? e.response?.data['error'] ?? 'Gagal mengirim email';
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<String> resetPassword(
      String email, String token, String newPassword) async {
    try {
      final response = await dio.post('/auth/reset-password', data: {
        'email': email,
        'token': token,
        'new_password': newPassword,
      });
      return response.data['message'] ?? 'Kata sandi berhasil diperbarui.';
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? e.response?.data['error'] ?? 'Gagal reset kata sandi';
    } catch (e) {
      throw e.toString();
    }
  }
}
