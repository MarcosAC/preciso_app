import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:preciso/presentation/viewmodels/auth_viewmodel.dart';
import 'package:preciso/presentation/views/auth/register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  LoginViewState createState() => LoginViewState();
}

class LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SizedBox(
              height: size.height,
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  const Icon(Icons.handyman, size: 80, color: Colors.blue),
                  const SizedBox(height: 8),
                  Text(
                    'PRECISO',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Encontre os melhores profissionais',
                    style: theme.textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Consumer<AuthViewModel>(
                    builder: (context, authViewModel, child) {
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Text(
                                  'Login',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                if (authViewModel.errorMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Text(
                                      authViewModel.errorMessage!,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.red,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                TextFormField(
                                  controller: _emailController,
                                  focusNode: _emailFocusNode,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.email),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  onFieldSubmitted: (_) {
                                    _emailFocusNode.unfocus();
                                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, insira seu email';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Email inválido';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocusNode,
                                  decoration: const InputDecoration(
                                    labelText: 'Senha',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.lock),
                                  ),
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) {
                                    _passwordFocusNode.unfocus();
                                    _login(authViewModel);
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, insira sua senha';
                                    }
                                    if (value.length < 6) {
                                      return 'Senha deve ter pelo menos 6 caracteres';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: authViewModel.isLoading
                                        ? null
                                        : () => _login(authViewModel),
                                    child: authViewModel.isLoading
                                        ? const CircularProgressIndicator(color: Colors.white)
                                        : const Text('Entrar'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Não tem uma conta?',
                        style: theme.textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterView(),
                            ),
                          );
                        },
                        child: Text(
                          'Cadastre-se',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login(AuthViewModel authViewModel) async {
    if (_formKey.currentState!.validate()) {
      final user = await authViewModel.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      if (user != null && mounted) {
        if (user.isProfessional) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/service_list',
            (Route<dynamic> route) => false,
          );
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home_client',
            (Route<dynamic> route) => false,
          );
        }
      }
    }
  }
}