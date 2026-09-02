import 'package:flutter/material.dart';

import '../../app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_widgets.dart';
import '../main_shell.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidden = true;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _enterApp() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (_) => false,
    );
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    try {
      await AuthService.instance.signInWithEmail(_email.text.trim(), _password.text);
      if (!mounted) return;
      _enterApp();
    } catch (e) {
      if (!mounted) return;
      EmptyActionSnack.show(context, e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _guestLogin() async {
    setState(() => _busy = true);
    try {
      await AuthService.instance.signInAnonymously();
      if (!mounted) return;
      _enterApp();
    } catch (e) {
      if (!mounted) return;
      EmptyActionSnack.show(context, e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageFrame(
      showBack: false,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Align(
                alignment: Alignment.center, child: BrandMark(size: 76)),
            const SizedBox(height: 22),
            Text(
              'مرحبًا بعودتك',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'أكمل رحلة التعلّم من حيث توقفت',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 15),
            ),
            const SizedBox(height: 30),
            TextFormField(
              key: const Key('login-email'),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني',
                hintText: 'name@example.com',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'أدخل البريد الإلكتروني';
                if (!text.contains('@') || !text.contains('.')) {
                  return 'أدخل بريدًا إلكترونيًا صحيحًا';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            TextFormField(
              key: const Key('login-password'),
              controller: _password,
              obscureText: _hidden,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _login(),
              decoration: InputDecoration(
                labelText: 'كلمة المرور',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: _hidden ? 'إظهار كلمة المرور' : 'إخفاء كلمة المرور',
                  onPressed: () => setState(() => _hidden = !_hidden),
                  icon: Icon(_hidden
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded),
                ),
              ),
              validator: (value) {
                if ((value ?? '').isEmpty) return 'أدخل كلمة المرور';
                if ((value ?? '').length < 6) return 'كلمة المرور قصيرة جدًا';
                return null;
              },
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen()),
                ),
                child: const Text('نسيت كلمة المرور؟'),
              ),
            ),
            FilledButton(
              key: const Key('login-button'),
              onPressed: _busy ? null : _login,
              child: _busy
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text('تسجيل الدخول'),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              key: const Key('guest-button'),
              onPressed: _busy ? null : _guestLogin,
              icon: const Icon(Icons.explore_outlined),
              label: const Text('تجربة التطبيق دون حساب'),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                const Expanded(child: Divider(color: AppColors.line)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child:
                      Text('أو', style: Theme.of(context).textTheme.bodyMedium),
                ),
                const Expanded(child: Divider(color: AppColors.line)),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _busy ? null : () => _guestLogin(),
              icon: const Icon(Icons.g_mobiledata_rounded, size: 30),
              label: const Text('المتابعة السريعة كزائر'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('ليس لديك حساب؟'),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: const Text('إنشاء حساب'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
