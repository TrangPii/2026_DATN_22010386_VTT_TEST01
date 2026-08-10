import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui/app_responsive.dart';
import '../../core/ui/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    await auth.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (!auth.isLoggedIn && auth.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(auth.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: AppResponsive.pagePadding(context, top: 24, bottom: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 56,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24.rw(context)),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20.rr(context)),
                        border: Border.all(color: AppColors.border),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0D0F172A),
                            blurRadius: 24,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Container(
                                width: 72.rw(context),
                                height: 72.rw(context),
                                decoration: BoxDecoration(
                                  color: AppColors.softBlue,
                                  borderRadius: BorderRadius.circular(
                                    22.rr(context),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.home_repair_service_rounded,
                                  size: 38.ri(context),
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            SizedBox(height: 24.rw(context)),
                            Text(
                              'Smart Service Hub',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30.rf(context),
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                height: 1.15,
                              ),
                            ),
                            SizedBox(height: 10.rw(context)),
                            Text(
                              'Đăng nhập để tiếp tục sử dụng dịch vụ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15.rf(context),
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 32.rw(context)),
                            Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 14.rf(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8.rw(context)),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              decoration: const InputDecoration(
                                hintText: 'Nhập địa chỉ email',
                                prefixIcon: Icon(Icons.mail_outline_rounded),
                              ),
                              validator: (value) {
                                final email = value?.trim() ?? '';
                                if (email.isEmpty) return 'Vui lòng nhập email';
                                if (!email.contains('@'))
                                  return 'Email không hợp lệ';
                                return null;
                              },
                            ),
                            SizedBox(height: 18.rw(context)),
                            Text(
                              'Mật khẩu',
                              style: TextStyle(
                                fontSize: 14.rf(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8.rw(context)),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              onFieldSubmitted: (_) {
                                if (!auth.isLoading) _login();
                              },
                              decoration: InputDecoration(
                                hintText: 'Nhập mật khẩu',
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                ),
                                suffixIcon: IconButton(
                                  tooltip: _obscurePassword
                                      ? 'Hiện mật khẩu'
                                      : 'Ẩn mật khẩu',
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Vui lòng nhập mật khẩu'
                                  : null,
                            ),
                            SizedBox(height: 26.rw(context)),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: auth.isLoading ? null : _login,
                                child: auth.isLoading
                                    ? SizedBox(
                                        width: 22.rw(context),
                                        height: 22.rw(context),
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Đăng nhập'),
                              ),
                            ),
                            SizedBox(height: 18.rw(context)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Chưa có tài khoản?',
                                    style: TextStyle(
                                      fontSize: 14.rf(context),
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: auth.isLoading
                                      ? null
                                      : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const RegisterScreen(),
                                            ),
                                          );
                                        },
                                  child: const Text('Đăng ký'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
