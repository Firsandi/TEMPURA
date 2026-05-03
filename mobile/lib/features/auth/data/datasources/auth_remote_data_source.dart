import 'package:dio/dio.dart';
import 'package:tempura/core/constants/api_constants.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String username, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio) {
    dio.options.baseUrl = ApiConstants.baseUrl;
  }

  @override
  Future<UserModel> login(String username, String password) async {
    try {
      final response = await dio.post(
        ApiConstants.loginEndpoint,
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return UserModel.fromJson(data);
      } else {
        throw response.data['message'] ?? 'Gagal login ke server';
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw e.response?.data['message'];
      }
      throw 'Terjadi kesalahan jaringan: ${e.message}';
    } catch (e) {
      throw 'Kesalahan tidak terduga: $e';
    }
  }
}
