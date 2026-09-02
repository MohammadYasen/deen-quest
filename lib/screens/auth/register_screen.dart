import 'package:flutter/material.dart';

import '../../app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_widgets.dart';
import '../main_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _hidden = true;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    try {
      await AuthService.instance.registerWithEmail(
        _email.text.trim(),
        _password.text,
        _name.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (_) => false,
      );
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Align(
                alignment: Alignment.center, child: BrandMark(size: 70)),
            const SizedBox(height: 20),
            Text(
              'إنشاء حساب جديد',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            const Text(
              'انضم إلى رحلة تعلّم متدرجة وممتعة',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 26),
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'الاسم أو اللقب',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) return 'أدخل اسمك أو لقبك';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
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
            const SizedBox(height: 14),
            TextFormField(
              controller: _password,
              obscureText: _hidden,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'كلمة المرور',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _hidden = !_hidden),
                  icon: Icon(_hidden
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded),
                ),
              ),
              validator: (value) {
                if ((value ?? '').isEmpty) return 'أدخل كلمة المرور';
                if ((value ?? '').length < 6) return 'يجب أن لا تقل عن 6 خانات';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _confirm,
              obscureText: _hidden,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _register(),
              decoration: const InputDecoration(
                labelText: 'تأكيد كلمة المرور',
                prefixIcon: Icon(Icons.lock_reset_rounded),
              ),
              validator: (value) {
                if (value != _password.text) return 'كلمات المرور غير متطابقة';
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy ? null : _register,
              child: _busy
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text('إنشاء الحساب والبدء'),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('لديك حساب بالفعل؟'),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('تسجيل الدخول'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
