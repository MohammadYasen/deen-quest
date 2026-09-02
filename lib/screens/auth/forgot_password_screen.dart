import 'package:flutter/material.dart';

import '../../app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _sent = false;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    try {
      await AuthService.instance.sendPasswordResetEmail(_email.text.trim());
      if (!mounted) return;
      setState(() => _sent = true);
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
              'استعادة كلمة المرور',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'أدخل بريدك الإلكتروني المسجل لنرسل لك رابط استعادة الحساب',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, height: 1.5),
            ),
            const SizedBox(height: 28),
            if (!_sent) ...[
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
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
              const SizedBox(height: 22),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text('إرسال رابط الاستعادة'),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: AppColors.primary, size: 34),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'تم إرسال رابط استعادة كلمة المرور بنجاح. تفقد صندوق الوارد والبريد غير الهام.',
                        style: TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                            height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('العودة لتسجيل الدخول'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
