import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/get_token_usecase.dart';
import '../../domain/usecases/load_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_notifier.dart';

class AuthServiceLocator {
  static Future<AuthNotifier> setup(SharedPreferences prefs) async {
    final localDataSource = AuthLocalDataSourceImpl(sharedPreferences: prefs);
    final remoteDataSource = AuthRemoteDataSourceImpl(client: http.Client());
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );

    final loginUseCase = LoginUseCase(authRepository);
    final logoutUseCase = LogoutUseCase(authRepository);
    final loadUserUseCase = LoadUserUseCase(authRepository);
    final getTokenUseCase = GetTokenUseCase(authRepository);
    return AuthNotifier(
      loginUseCase: loginUseCase,
      logoutUseCase: logoutUseCase,
      loadUserUseCase: loadUserUseCase,
      getTokenUseCase: getTokenUseCase,
    );
  }
}
