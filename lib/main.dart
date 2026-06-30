import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api/wallet_api_client.dart';
import 'core/repositories/wallet_repository.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'features/dashboard/dashboard_provider.dart';
import 'features/auth/auth_provider.dart';
import 'features/transfers/transfers_provider.dart';

void main() {
  runApp(
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
        ChangeNotifierProxyProvider<WalletRepository, AuthProvider>(
          create: (context) => AuthProvider(Provider.of<WalletRepository>(context, listen: false)),
          update: (_, repository, previous) => previous ?? AuthProvider(repository),
        ),
        ChangeNotifierProxyProvider2<WalletRepository, DashboardProvider, TransfersProvider>(
          create: (context) => TransfersProvider(
            Provider.of<WalletRepository>(context, listen: false),
            Provider.of<DashboardProvider>(context, listen: false),
          ),
          update: (_, repository, dashboard, previous) =>
              previous ?? TransfersProvider(repository, dashboard),
        ),
      ],
      child: const BadWalletApp(),
    ),
  );
}

class BadWalletApp extends StatelessWidget {
  const BadWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BadWallet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
