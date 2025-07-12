import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:preciso/domain/entities/user_entity.dart';
import 'package:preciso/presentation/views/auth/register_view.dart';
import 'package:preciso/presentation/views/client/home_client_view.dart';
import 'package:preciso/presentation/views/professional/service_list_view.dart';
import 'package:provider/provider.dart';

// Repositories (interfaces ou implementações diretas se não houver interface específica aqui)
import 'package:preciso/data/repositories/auth_repository.dart';
import 'package:preciso/data/repositories/service_repository.dart';
import 'package:preciso/data/repositories/user_repository.dart';

// Use Cases - Importar individualmente para instanciar corretamente
import 'package:preciso/domain/usecases/auth_usecases.dart'; // Contém LoginUseCase, RegisterClientUseCase, etc.
import 'package:preciso/domain/usecases/service_usecases.dart'; // Contém GetClientRequestsUseCase, UpdateRequestStatusUseCase, etc.
import 'package:preciso/domain/usecases/user_usecases.dart'; // Contém GetUserByIdUseCase, UpdateUserProfileUseCase, etc.

// ViewModels
import 'package:preciso/presentation/viewmodels/auth_viewmodel.dart';
import 'package:preciso/presentation/viewmodels/service_viewmodel.dart';
import 'package:preciso/presentation/viewmodels/professional_viewmodel.dart';
import 'package:preciso/presentation/viewmodels/user_viewmodel.dart';
import 'package:preciso/presentation/viewmodels/profile_viewmodel.dart';

// Views
import 'package:preciso/presentation/views/auth/login_view.dart';
import 'package:preciso/presentation/views/client/home_client_view.dart';
import 'package:preciso/presentation/views/professional/home_professional_view.dart';
import 'package:preciso/presentation/views/client/profile/client_profile_screen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Provider.debugCheckInvalidValueType = null;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // --- Firebase Services ---
        Provider<FirebaseAuth>(create: (_) => FirebaseAuth.instance),
        Provider<FirebaseFirestore>(create: (_) => FirebaseFirestore.instance),
        Provider<FirebaseStorage>(create: (_) => FirebaseStorage.instance),
        Provider<DatabaseReference>(
          create: (_) => FirebaseDatabase.instance.ref(),
        ),

        // --- Repositories ---
        // AuthRepository
        Provider<AuthRepository>(
          create: (context) => AuthRepository(firebaseAuth: context.read<FirebaseAuth>()),
        ),
        // ServiceRepository
        Provider<ServiceRepository>(
          create: (context) => ServiceRepository(
            auth: context.read<FirebaseAuth>(),
            dbRef: context.read<DatabaseReference>(),
            storage: context.read<FirebaseStorage>(),
          ),
        ),
        // UserRepository
        Provider<UserRepository>(
          create: (context) => UserRepository(
            firebaseAuth: context.read<FirebaseAuth>(),
            dbRef: context.read<DatabaseReference>(),
            storage: context.read<FirebaseStorage>(),
          ),
        ),

        // --- Use Cases ---
        // Auth Use Cases
        Provider<LoginUseCase>(
          create: (context) => LoginUseCase(context.read<AuthRepository>()),
        ),
        Provider<RegisterClientUseCase>(
          create: (context) => RegisterClientUseCase(context.read<AuthRepository>()),
        ),
        Provider<RegisterProfessionalUseCase>(
          create: (context) => RegisterProfessionalUseCase(context.read<AuthRepository>()),
        ),
        Provider<LogoutUseCase>(
          create: (context) => LogoutUseCase(context.read<AuthRepository>()),
        ),

        // User Use Cases (Movi para cá para garantir que estejam disponíveis antes dos ViewModels que os usam)
        Provider<GetUserByIdUseCase>(
          create: (context) => GetUserByIdUseCase(context.read<UserRepository>()),
        ),
        Provider<UpdateUserProfileUseCase>(
          create: (context) => UpdateUserProfileUseCase(context.read<UserRepository>()),
        ),
        Provider<UploadProfileImageUseCase>(
          create: (context) => UploadProfileImageUseCase(context.read<UserRepository>()),
        ),
        // Adicione outros User Use Cases aqui, se houver (e.g., GetProfessionalsByServiceUseCase)
        Provider<GetProfessionalsByServiceUseCase>(
          create: (context) => GetProfessionalsByServiceUseCase(context.read<UserRepository>()),
        ),


        // Service Use Cases (Todos necessários para o ServiceViewModel)
        Provider<GetClientRequestsUseCase>(
          create: (context) => GetClientRequestsUseCase(context.read<ServiceRepository>()),
        ),
        Provider<GetAvailableRequestsUseCase>(
          create: (context) => GetAvailableRequestsUseCase(context.read<ServiceRepository>()),
        ),
        Provider<CreateServiceRequestUseCase>(
          create: (context) => CreateServiceRequestUseCase(context.read<ServiceRepository>()),
        ),
        Provider<UpdateRequestStatusUseCase>(
          create: (context) => UpdateRequestStatusUseCase(context.read<ServiceRepository>()),
        ),
        Provider<RateProfessionalUseCase>(
          create: (context) => RateProfessionalUseCase(context.read<ServiceRepository>()),
        ),

        // --- ViewModels ---
        // AuthViewModel
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(
            loginUseCase: context.read<LoginUseCase>(),
            registerClientUseCase: context.read<RegisterClientUseCase>(),
            registerProfessionalUseCase: context.read<RegisterProfessionalUseCase>(),
            logoutUseCase: context.read<LogoutUseCase>(),
          ),
        ),

        // ServiceViewModel (Agora com construtor e injeção direta de Use Cases)
        ChangeNotifierProvider<ServiceViewModel>(
          create: (context) => ServiceViewModel(
            getClientRequestsUseCase: context.read<GetClientRequestsUseCase>(),
            getAvailableRequestsUseCase: context.read<GetAvailableRequestsUseCase>(),
            createServiceRequestUseCase: context.read<CreateServiceRequestUseCase>(),
            updateRequestStatusUseCase: context.read<UpdateRequestStatusUseCase>(),
            rateProfessionalUseCase: context.read<RateProfessionalUseCase>(),
          ),
        ),

        // ProfessionalViewModel
        // Adaptei para usar Use Cases, se o seu ProfessionalViewModel também tem métodos
        // que chamam use cases específicos, você os injetaria aqui.
        // Se GetAvailableRequestsUseCase for o principal para ele, use-o.
        ChangeNotifierProvider<ProfessionalViewModel>(
          create: (context) => ProfessionalViewModel(
            getAvailableRequestsUseCase: context.read<GetAvailableRequestsUseCase>(),
            getUserByIdUseCase: context.read<GetUserByIdUseCase>(),
            updateRequestStatusUseCase: context.read<UpdateRequestStatusUseCase>(),            
            getProfessionalsByServiceUseCase: context.read<GetProfessionalsByServiceUseCase>(),
            createServiceRequestUseCase: context.read<CreateServiceRequestUseCase>(),
          ),
        ),


        // UserViewModel
        // Também adaptado para injeção direta de Use Cases no construtor
        ChangeNotifierProvider<UserViewModel>(
          create: (context) => UserViewModel(
            getProfessionalsByServiceUseCase: context.read<GetProfessionalsByServiceUseCase>(),
            getUserByIdUseCase: context.read<GetUserByIdUseCase>(),
            updateUserProfileUseCase: context.read<UpdateUserProfileUseCase>(),
            uploadProfileImageUseCase: context.read<UploadProfileImageUseCase>(),
          ),
        ),

        // ProfileViewModel (já estava usando injeção direta)
        ChangeNotifierProvider<ProfileViewModel>(
          create: (context) => ProfileViewModel(
            getUserByIdUseCase: context.read<GetUserByIdUseCase>(),
            updateUserProfileUseCase: context.read<UpdateUserProfileUseCase>(),
            uploadProfileImageUseCase: context.read<UploadProfileImageUseCase>(),
            logoutUseCase: context.read<LogoutUseCase>(),
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
          '/service_list': (context) => const ServiceListView(),
          '/client_profile': (context) => ClientProfileScreen(
            userId: Provider.of<AuthViewModel>(context, listen: false).currentUser?.uid ?? '',
          ),
          // Se você tiver uma rota para DetailServiceView, pode adicioná-la aqui,
          // mas geralmente ela é acessada por argumentos.
          // '/detail_service': (context) => DetailServiceView(service: /* passe ServiceEntity aqui */),
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
    final authViewModel = Provider.of<AuthViewModel>(context);
    return StreamBuilder<UserEntity?>(
      stream: authViewModel.userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data ?? authViewModel.currentUser;

        if (user != null) {
          // Note: Verifique se ServiceListView é a HomeProfessionalView que você realmente quer mostrar
          // ou se você tem uma HomeProfessionalView separada.
          return user.isProfessional
              ? const ServiceListView() // Ou const HomeProfessionalView() se for a tela principal
              : const HomeClientView();
        }
        return const LoginView();
      },
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:preciso/domain/entities/user_entity.dart';
// import 'package:preciso/presentation/views/auth/register_view.dart';
// import 'package:preciso/presentation/views/professional/service_list_view.dart';
// import 'package:provider/provider.dart';
// import 'package:preciso/data/repositories/auth_repository.dart';
// import 'package:preciso/data/repositories/service_repository.dart';
// import 'package:preciso/data/repositories/user_repository.dart';
// import 'package:preciso/domain/usecases/auth_usecases.dart';
// import 'package:preciso/domain/usecases/service_usecases.dart';
// import 'package:preciso/domain/usecases/user_usecases.dart';
// import 'package:preciso/presentation/viewmodels/auth_viewmodel.dart';
// import 'package:preciso/presentation/viewmodels/service_viewmodel.dart';
// import 'package:preciso/presentation/viewmodels/professional_viewmodel.dart';
// import 'package:preciso/presentation/viewmodels/user_viewmodel.dart';
// import 'package:preciso/presentation/viewmodels/profile_viewmodel.dart';
// import 'package:preciso/presentation/views/auth/login_view.dart';
// import 'package:preciso/presentation/views/client/home_client_view.dart';
// import 'package:preciso/presentation/views/professional/home_professional_view.dart';
// import 'package:preciso/presentation/views/client/profile/client_profile_screen.dart';
// import 'firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   Provider.debugCheckInvalidValueType = null;
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         // Firebase Services
//         Provider<FirebaseAuth>(create: (_) => FirebaseAuth.instance),
//         Provider<FirebaseFirestore>(create: (_) => FirebaseFirestore.instance),
//         Provider<FirebaseStorage>(create: (_) => FirebaseStorage.instance),
//         Provider<DatabaseReference>(
//           create: (_) => FirebaseDatabase.instance.ref(),
//         ),

//         // Repositories
//         Provider<AuthRepository>(
//           create:
//               (context) =>
//                   AuthRepository(firebaseAuth: context.read<FirebaseAuth>()),
//         ),

//         Provider<ServiceRepository>(
//           create:
//               (context) => ServiceRepository(
//                 auth: context.read<FirebaseAuth>(),
//                 dbRef: context.read<DatabaseReference>(),
//                 storage: context.read<FirebaseStorage>(),
//               ),
//         ),

//         Provider<UserRepository>(
//           create:
//               (context) => UserRepository(
//                 firebaseAuth: context.read<FirebaseAuth>(),
//                 dbRef: context.read<DatabaseReference>(),
//                 storage: context.read<FirebaseStorage>(),
//               ),
//         ),

//         // Use Cases
//         Provider<LoginUseCase>(
//           create: (context) => LoginUseCase(context.read<AuthRepository>()),
//         ),

//         Provider<RegisterClientUseCase>(
//           create:
//               (context) =>
//                   RegisterClientUseCase(context.read<AuthRepository>()),
//         ),

//         Provider<RegisterProfessionalUseCase>(
//           create: 
//               (context) => 
//                   RegisterProfessionalUseCase(context.read<AuthRepository>()),
//         ),

//         Provider<LogoutUseCase>(
//           create: (context) => LogoutUseCase(context.read<AuthRepository>()),
//         ),

//         Provider<GetUserByIdUseCase>(
//           create:
//               (context) => GetUserByIdUseCase(context.read<UserRepository>()),
//         ),

//         Provider<UpdateUserProfileUseCase>(
//           create:
//               (context) =>
//                   UpdateUserProfileUseCase(context.read<UserRepository>()),
//         ),

//         Provider<UploadProfileImageUseCase>(
//           create:
//               (context) =>
//                   UploadProfileImageUseCase(context.read<UserRepository>()),
//         ),

//          ChangeNotifierProvider<AuthViewModel>(
//           create: (context) => AuthViewModel(
//             loginUseCase: context.read<LoginUseCase>(),
//             registerClientUseCase: context.read<RegisterClientUseCase>(),
//             registerProfessionalUseCase: context.read<RegisterProfessionalUseCase>(),
//             logoutUseCase: context.read<LogoutUseCase>(),
//           ),
//         ),

//         ChangeNotifierProvider<ProfileViewModel>(
//           create:
//               (context) => ProfileViewModel(
//                 getUserByIdUseCase: context.read<GetUserByIdUseCase>(),
//                 updateUserProfileUseCase: context.read<UpdateUserProfileUseCase>(),
//                 uploadProfileImageUseCase:context.read<UploadProfileImageUseCase>(),
//                 logoutUseCase: context.read<LogoutUseCase>(),
//               ),
//         ),

//         ChangeNotifierProxyProvider<ServiceRepository, ServiceViewModel>(
//           create: (_) => ServiceViewModel(),
//           update:
//               (_, serviceRepo, viewModel) =>
//                   viewModel!..updateDependencies(
//                     getClientRequestsUseCase: GetClientRequestsUseCase(serviceRepo),
//                     getAvailableRequestsUseCase: GetAvailableRequestsUseCase(serviceRepo),
//                     createServiceRequestUseCase: CreateServiceRequestUseCase(serviceRepo),
//                     updateRequestStatusUseCase: UpdateRequestStatusUseCase(serviceRepo),
//                     rateProfessionalUseCase: RateProfessionalUseCase(serviceRepo),
//                   ),
//         ),

//         ChangeNotifierProxyProvider2<
//           UserRepository,
//           ServiceRepository,
//           ProfessionalViewModel
//         >(create: (_) => ProfessionalViewModel(),
//           update:(_, userRepo, serviceRepo, viewModel) =>
//                   viewModel!..updateDependencies(
//                     userRepository: userRepo,
//                     serviceRepository: serviceRepo,
//                   ),
//         ),

//         ChangeNotifierProxyProvider<UserRepository, UserViewModel>(
//           create: (_) => UserViewModel(),
//           update:(_, userRepo, viewModel) =>
//                   viewModel!..updateDependencies(
//                     getProfessionalsByServiceUseCase: GetProfessionalsByServiceUseCase(userRepo),
//                     getUserByIdUseCase: GetUserByIdUseCase(userRepo),
//                     updateUserProfileUseCase: UpdateUserProfileUseCase(userRepo),
//                     uploadProfileImageUseCase: UploadProfileImageUseCase(userRepo),
//                   ),
//         ),

//         // Use Cases individuais
//         Provider<GetUserByIdUseCase>(create: (context) => GetUserByIdUseCase(Provider.of<UserRepository>(context, listen: false))),
//         Provider<UpdateUserProfileUseCase>(create: (context) => UpdateUserProfileUseCase(Provider.of<UserRepository>(context, listen: false))),
//         Provider<UploadProfileImageUseCase>(create: (context) => UploadProfileImageUseCase(Provider.of<UserRepository>(context, listen: false))),

//         // Profile ViewModel
//         ChangeNotifierProvider<ProfileViewModel>(
//           create: (context) => ProfileViewModel(
//             getUserByIdUseCase: Provider.of<GetUserByIdUseCase>(context, listen: false),
//             updateUserProfileUseCase: Provider.of<UpdateUserProfileUseCase>(context,listen: false),
//             uploadProfileImageUseCase: Provider.of<UploadProfileImageUseCase>(context, listen: false),
//             logoutUseCase: Provider.of<LogoutUseCase>(context,listen: false),
//           ),
//         ),
//       ],
//       child: MaterialApp(
//         title: 'Preciso',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//           visualDensity: VisualDensity.adaptivePlatformDensity,
//         ),
//         initialRoute: '/',
//         routes: {
//           '/': (context) => const AuthWrapper(),
//           '/login': (context) => const LoginView(),
//           '/home_client': (context) => const HomeClientView(),
//           '/home_professional': (context) => const HomeProfessionalView(),
//           '/register': (context) => const RegisterView(),
//           '/client_profile':
//               (context) => ClientProfileScreen(
//                 userId:
//                     Provider.of<AuthViewModel>(
//                       context,
//                       listen: false,
//                     ).currentUser?.uid ??
//                     '',
//               ),
//         },
//         debugShowCheckedModeBanner: false,
//       ),
//     );
//   }
// }

// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authViewModel = Provider.of<AuthViewModel>(context);
//     return StreamBuilder<UserEntity?>(       
//       stream: authViewModel.userStream,      
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         final user = snapshot.data ?? authViewModel.currentUser;

//         if (user != null) {
//           return user.isProfessional
//               ? const ServiceListView() //HomeProfessionalView()
//               : const HomeClientView();
//         }
//         return const LoginView();
//       },
//     );
//   }
// }
