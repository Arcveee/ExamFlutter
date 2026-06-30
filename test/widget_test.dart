import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:badwallet_mobile/main.dart';
import 'package:badwallet_mobile/core/api/wallet_api_client.dart';
import 'package:badwallet_mobile/core/repositories/wallet_repository.dart';
import 'package:badwallet_mobile/features/dashboard/dashboard_provider.dart';

void main() {
  testWidgets('App loads placeholder', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<WalletApiClient>(
            create: (_) => WalletApiClient(),
          ),
          ProxyProvider<WalletApiClient, WalletRepository>(
            update: (_, apiClient, __) => WalletRepository(apiClient),
          ),
          ChangeNotifierProxyProvider<WalletRepository, DashboardProvider>(
            create: (context) => DashboardProvider(Provider.of<WalletRepository>(context, listen: false)),
            update: (_, repository, previous) => previous ?? DashboardProvider(repository),
          ),
        ],
        child: const BadWalletApp(),
      ),
    );

    expect(find.byType(BadWalletApp), findsOneWidget);
  });
}
