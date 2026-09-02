import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../progress_store.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../widgets/app_widgets.dart';
import 'auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _pickTime(BuildContext context) async {
    final progress = GameProgress.instance;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: progress.reminderHour, minute: progress.reminderMinute),
    );
    if (picked != null) {
      progress.setReminderTime(picked.hour, picked.minute);
      await NotificationService.instance.scheduleDailyReminder(picked);
      if (context.mounted) {
        EmptyActionSnack.show(context, 'تم ضبط وقت التذكير على ${picked.format(context)}.');
      }
    }
  }

  void _showDailyGoalDialog(BuildContext context) {
    final progress = GameProgress.instance;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('اختر هدفك اليومي'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [1, 2, 3, 5].map((count) {
            return RadioListTile<int>(
              title: Text('$count ${count == 1 ? 'درس' : 'دروس'} يومياً'),
              value: count,
              groupValue: progress.dailyGoalLessons,
              onChanged: (val) {
                if (val != null) {
                  progress.setDailyGoal(val);
                  Navigator.pop(ctx);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(content, style: const TextStyle(height: 1.6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الحساب نهائياً'),
        content: const Text(
          'هل أنت متأكد من رغبتك في حذف حسابك؟ سيتم مسح كافة نقاطك وتقدمك وسلسلة أيامك ولا يمكن التراجع عن هذا الإجراء.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.instance.deleteAccount();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
            child: const Text('حذف الحساب'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد حقاً تسجيل الخروج من حسابك؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
            child: const Text('تأكيد الخروج'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: GameProgress.instance,
      builder: (context, _) {
        final progress = GameProgress.instance;
        final timeStr = '${progress.reminderHour.toString().padLeft(2, '0')}:${progress.reminderMinute.toString().padLeft(2, '0')}';

        return Scaffold(
          appBar: AppBar(title: const Text('الإعدادات')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
            children: [
              const _GroupTitle('التعلّم والتذكيرات'),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      value: progress.notificationsEnabled,
                      onChanged: (value) async {
                        if (value) {
                          final granted = await NotificationService.instance.requestPermissions();
                          progress.toggleNotifications(granted);
                        } else {
                          progress.toggleNotifications(false);
                        }
                      },
                      secondary: const Icon(Icons.notifications_active_outlined,
                          color: AppColors.primary),
                      title: const Text('تذكير الهدف اليومي'),
                      subtitle: Text('وقت التنبيه: $timeStr'),
                    ),
                    if (progress.notificationsEnabled) ...[
                      const Divider(height: 1, indent: 70),
                      ListTile(
                        leading: const SizedBox(width: 24),
                        title: const Text('تغيير وقت التذكير'),
                        trailing: Text(timeStr, style: const TextStyle(fontWeight: FontWeight.w800)),
                        onTap: () => _pickTime(context),
                      ),
                    ],
                    const Divider(height: 1, indent: 70),
                    SwitchListTile(
                      value: progress.soundEnabled,
                      onChanged: (value) => progress.toggleSound(value),
                      secondary: const Icon(Icons.volume_up_outlined,
                          color: AppColors.primary),
                      title: const Text('المؤثرات الصوتية'),
                    ),
                    const Divider(height: 1, indent: 70),
                    SwitchListTile(
                      value: progress.hapticEnabled,
                      onChanged: (value) => progress.toggleHaptics(value),
                      secondary: const Icon(Icons.vibration_rounded,
                          color: AppColors.primary),
                      title: const Text('الاهتزاز والتفاعل'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const _GroupTitle('المظهر والهدف'),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      value: progress.isDarkMode,
                      onChanged: (value) => progress.toggleDarkMode(value),
                      secondary: const Icon(Icons.dark_mode_outlined,
                          color: AppColors.primary),
                      title: const Text('الوضع الداكن'),
                      subtitle: const Text('تصميم ليلي مريح للعينين'),
                    ),
                    const Divider(height: 1, indent: 70),
                    ListTile(
                      leading: const Icon(Icons.flag_outlined, color: AppColors.primary),
                      title: const Text('الهدف اليومي'),
                      subtitle: Text('${progress.dailyGoalLessons} دروس يومياً'),
                      trailing: const Icon(Icons.chevron_left_rounded),
                      onTap: () => _showDailyGoalDialog(context),
                    ),
                    const Divider(height: 1, indent: 70),
                    const ListTile(
                      leading: Icon(Icons.language_rounded, color: AppColors.primary),
                      title: Text('لغة التطبيق'),
                      trailing: Text('العربية (افتراضي)', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const _GroupTitle('المعلومات والخصوصية'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.verified_user_outlined, color: AppColors.primary),
                      title: const Text('تنبيه المحتوى التعليمي'),
                      trailing: const Icon(Icons.chevron_left_rounded),
                      onTap: () => _showInfoDialog(
                        context,
                        'تنبيه الأمانة العلمية',
                        'تطبيق «رحلة النور» هو منصة تعليمية تفاعلية تهدف إلى تيسير تعلم المعارف الإسلامية الأساسية بالاستناد إلى القرآن الكريم والحديث الصحيح.\n\nالمحتوى تعليمي وتثقيفي ولا يمثل فتاوى شرعية خاصة، ونحث دائماً على الرجوع إلى العلماء والجهات الإفتائية الرسمية في المسائل الخاصة والشخصية.',
                      ),
                    ),
                    const Divider(height: 1, indent: 70),
                    ListTile(
                      leading: const Icon(Icons.shield_outlined, color: AppColors.primary),
                      title: const Text('سياسة الخصوصية'),
                      trailing: const Icon(Icons.chevron_left_rounded),
                      onTap: () => _showInfoDialog(
                        context,
                        'سياسة الخصوصية',
                        'نحن نحترم خصوصيتك تماماً. لا يقوم تطبيق رحلة النور بجمع أي بيانات شخصية غير ضرورية، ويتم تخزين تقدمك التعليمي محلياً على جهازك وبأمان عبر الحساب السحابي في حال تسجيل الدخول.',
                      ),
                    ),
                    const Divider(height: 1, indent: 70),
                    ListTile(
                      leading: const Icon(Icons.description_outlined, color: AppColors.primary),
                      title: const Text('شروط الاستخدام'),
                      trailing: const Icon(Icons.chevron_left_rounded),
                      onTap: () => _showInfoDialog(
                        context,
                        'شروط الاستخدام',
                        'استخدامك لتطبيق رحلة النور يعني موافقتك على استخدامه في إطار التعلم والتثقيف الهادف وفق الضوابط الشرعية والأخلاقية.',
                      ),
                    ),
                    const Divider(height: 1, indent: 70),
                    ListTile(
                      leading: const Icon(Icons.help_outline_rounded, color: AppColors.primary),
                      title: const Text('المساعدة والتواصل'),
                      trailing: const Icon(Icons.chevron_left_rounded),
                      onTap: () => _showInfoDialog(
                        context,
                        'المساعدة والدعم',
                        'نسعد بتواصلكم وملاحظاتكم لتطوير التطبيق وخدمة طلاب العلم:\n\nالبريد الإلكتروني: support@deenquest.app\nنسخة التطبيق: 1.0.0 (رحلة النور)',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => _confirmLogout(context),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('تسجيل الخروج'),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => _confirmDeleteAccount(context),
                style: TextButton.styleFrom(foregroundColor: AppColors.muted),
                icon: const Icon(Icons.delete_forever_rounded),
                label: const Text('حذف الحساب نهائياً'),
              ),
              const SizedBox(height: 16),
              const Text('رحلة النور · الإصدار 1.0.0 (بناء 1)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, fontSize: 12)),
            ],
          ),
        );
      },
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
      child: Text(title,
          style: const TextStyle(
              color: AppColors.primaryDark, fontWeight: FontWeight.w900)),
    );
  }
}
