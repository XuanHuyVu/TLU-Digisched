import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../../config/constants/constants.dart';
import '../models/user_model.dart';
import '../../../../config/constants/api_endpoints.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> login(String email, String password) async {
    final uri = Uri.parse(ApiEndpoints.login);

    try {
      final response = await client
          .post(uri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              Constants.email: email,
              Constants.password: password
            }),
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['data']?['accessToken'] as String?;
        if (accessToken == null) throw Exception('No access token in response');
        final decodedToken = JwtDecoder.decode(accessToken);
        final uid = decodedToken['uid'] as int?;
        final role = decodedToken['role'] as String?;
        final userEmail = decodedToken['sub'] as String?;
        if (uid == null || role == null || userEmail == null) {
          throw Exception('Invalid token structure');
        }

        final user = UserModel(
          username: userEmail,
          token: accessToken,
          role: role,
          id: uid,
        );
        return user;
      } else {
        final errorData = jsonDecode(response.body);
        final message = errorData['message'] ?? 'Login failed';
        throw Exception(message);
      }
    } on TimeoutException {
      throw Exception(
        'Connection timeout. Please check your network and try again.',
      );
    } catch (ex) {
      throw Exception('Login failed: ${ex.toString()}');
    }
  }
}
