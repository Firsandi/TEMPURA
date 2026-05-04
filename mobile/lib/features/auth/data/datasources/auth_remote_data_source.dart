import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<String> forgotPassword(String email);
  Future<String> resetPassword(String email, String token, String newPassword);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return UserModel(
          id: response.user!.id,
          username: response.user!.email?.split('@')[0] ?? 'user',
          fullName: response.user!.userMetadata?['full_name'] ?? 'User',
          role: response.user!.userMetadata?['role']?.toString() ?? '2',
        );
      } else {
        throw 'Gagal login: User tidak ditemukan';
      }
    } catch (e) {
      throw e.toString().replaceAll('AuthException: ', '');
    }
  }

  @override
  Future<String> forgotPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
      return 'Email pemulihan kata sandi telah dikirim.';
    } catch (e) {
      throw e.toString().replaceAll('AuthException: ', '');
    }
  }

  @override
  Future<String> resetPassword(
      String email, String token, String newPassword) async {
    try {
      // Supabase uses verifyOTP for email reset tokens
      await supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );

      // After verification, update the password
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      return 'Kata sandi berhasil diperbarui.';
    } catch (e) {
      throw e.toString().replaceAll('AuthException: ', '');
    }
  }
}
