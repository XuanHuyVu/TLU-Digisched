import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tlu_digisched/main.dart';
import 'package:tlu_digisched/features/auth/presentation/notifiers/auth_service_locator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App loads successfully',
          (WidgetTester tester) async {
        final prefs = await SharedPreferences.getInstance();
        final authNotifier = await AuthServiceLocator.setup(prefs);
        await tester.pumpWidget(
          MyApp(authNotifier: authNotifier),
        );
        expect(find.byType(MyApp), findsOneWidget);
      });
}