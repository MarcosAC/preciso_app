import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:preciso/presentation/views/auth/register_view.dart';
import 'package:provider/provider.dart';
import 'package:preciso/data/repositories/auth_repository.dart';
import 'package:preciso/data/repositories/service_repository.dart';
import 'package:preciso/data/repositories/user_repository.dart';
import 'package:preciso/domain/usecases/auth_usecases.dart';
import 'package:preciso/domain/usecases/service_usecases.dart';
import 'package:preciso/domain/usecases/user_usecases.dart';
import 'package:preciso/presentation/viewmodels/auth_viewmodel.dart';
import 'package:preciso/presentation/viewmodels/service_viewmodel.dart';
import 'package:preciso/presentation/viewmodels/professional_viewmodel.dart';
import 'package:preciso/presentation/viewmodels/user_viewmodel.dart';
import 'package:preciso/presentation/views/auth/login_view.dart';
import 'package:preciso/presentation/views/client/home_client_view.dart';
import 'package:preciso/presentation/views/professional/home_professional_view.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  Provider.debugCheckInvalidValueType = null;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Firebase Services
        Provider<FirebaseAuth>(create: (_) => FirebaseAuth.instance),
        Provider<FirebaseFirestore>(create: (_) => FirebaseFirestore.instance),
        Provider<FirebaseStorage>(create: (_) => FirebaseStorage.instance),

        // Repositories
        ProxyProvider<FirebaseAuth, AuthRepository>(
          update: (_, auth, __) => AuthRepository(firebaseAuth: auth),
        ),

        ProxyProvider3<FirebaseAuth, FirebaseFirestore, FirebaseStorage, ServiceRepository>(
          update: (_, auth, firestore, storage, __) => ServiceRepository(
            auth: auth,
            firestore: firestore,
            storage: storage,
          ),
        ),

        ProxyProvider2<FirebaseFirestore, FirebaseStorage, UserRepository>(
          update: (_, firestore, storage, __) => UserRepository(
            firestore: firestore,
            storage: storage,
          ),
        ),

        // ViewModels
        ChangeNotifierProxyProvider<AuthRepository, AuthViewModel>(
          create: (_) => AuthViewModel(),
          update: (_, authRepo, viewModel) => viewModel!..updateDependencies(
            loginUseCase: LoginUseCase(authRepo),
            registerClientUseCase: RegisterClientUseCase(authRepo),
            logoutUseCase: LogoutUseCase(authRepo),
          ),
        ),

        ChangeNotifierProxyProvider<ServiceRepository, ServiceViewModel>(
          create: (_) => ServiceViewModel(), // Agora pode ser criado sem parâmetros
          update: (_, serviceRepo, viewModel) => viewModel!..updateDependencies(
            getClientRequestsUseCase: GetClientRequestsUseCase(serviceRepo),
            getAvailableRequestsUseCase: GetAvailableRequestsUseCase(serviceRepo),
            createServiceRequestUseCase: CreateServiceRequestUseCase(serviceRepo),
            updateRequestStatusUseCase: UpdateRequestStatusUseCase(serviceRepo),
            rateProfessionalUseCase: RateProfessionalUseCase(serviceRepo),
          ),
        ),

        ChangeNotifierProxyProvider2<UserRepository, ServiceRepository, ProfessionalViewModel>(
          create: (_) => ProfessionalViewModel(), // Agora pode ser criado sem parâmetros
          update: (_, userRepo, serviceRepo, viewModel) => viewModel!..updateDependencies(
            userRepository: userRepo,
            serviceRepository: serviceRepo,
          ),
        ),
        
        ChangeNotifierProxyProvider<UserRepository, UserViewModel>(
          create: (_) => UserViewModel(),
          update: (_, userRepo, viewModel) => viewModel!..updateDependencies(
            getProfessionalsByServiceUseCase: GetProfessionalsByServiceUseCase(userRepo),
            getUserByIdUseCase: GetUserByIdUseCase(userRepo),
            updateUserProfileUseCase: UpdateUserProfileUseCase(userRepo),
            registerProfessionalUseCase: RegisterProfessionalUseCase(userRepo),
            uploadProfileImageUseCase: UploadProfileImageUseCase(userRepo),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Preciso',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(),
          '/login': (context) => const LoginView(),
          '/home_client': (context) => const HomeClientView(),
          '/home_professional': (context) => const HomeProfessionalView(),
          '/register': (context) => const RegisterView(),
        },
        
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    return StreamBuilder(
      stream: authViewModel.userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData && snapshot.data != null) {
            return snapshot.data!.isProfessional
                ? const HomeProfessionalView()
                : const HomeClientView();
          }
          return const LoginView();
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}