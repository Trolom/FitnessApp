import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/validators.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _obscure = true;
  bool _obscure2 = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Create account
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      // Update display name (optional)
      await FirebaseAuth.instance.currentUser
          ?.updateDisplayName(_name.text.trim());

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Registration failed');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(_error!,
                            style: const TextStyle(color: Colors.red)),
                      ),

                    /// FULL NAME
                    AuthTextField(
                      controller: _name,
                      label: 'Full name',
                      validator: Validators.nonEmpty,
                    ),
                    const SizedBox(height: 16),

                    /// EMAIL
                    AuthTextField(
                      controller: _email,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),

                    /// PASSWORD
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 16),

                    /// CONFIRM PASSWORD
                    TextFormField(
                      controller: _confirm,
                      obscureText: _obscure2,
                      decoration: InputDecoration(
                        labelText: 'Confirm password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscure2 = !_obscure2),
                          icon: Icon(
                            _obscure2
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: (v) =>
                          Validators.confirmPassword(v, _password.text),
                    ),
                    const SizedBox(height: 20),

                    /// BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _loading ? null : _submit,
                        child: _loading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Create account'),
                      ),
                    ),
                    const SizedBox(height: 12),

                    /// GO TO LOGIN
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () => Navigator.of(context)
                              .pushReplacementNamed('/login'),
                      child: const Text('Already have an account? Log in'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
