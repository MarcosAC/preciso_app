import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:preciso/data/repositories/auth_repository.dart';
import 'package:preciso/domain/usecases/auth_usecases.dart';
import 'package:preciso/presentation/viewmodels/auth_viewmodel.dart';
import 'package:preciso/presentation/views/auth/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
        ProxyProvider<AuthRepository, AuthViewModel>(
          update: (_, authRepo, __) => AuthViewModel(
            loginUseCase: LoginUseCase(authRepo),
            registerClientUseCase: RegisterClientUseCase(authRepo),
            logoutUseCase: LogoutUseCase(authRepo),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Preciso',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return StreamBuilder(
      stream: authViewModel.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            // Navegar para a tela principal apropriada
            return const Scaffold(body: Center(child: Text('Home Screen')));
          } else {
            return const LoginView();
          }
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}