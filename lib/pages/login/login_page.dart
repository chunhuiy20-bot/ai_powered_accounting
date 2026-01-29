import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_first_app/pages/login/register_page.dart';

import '../main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 控制器
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 状态变量
  bool _isAgreed = false;           // 是否同意协议
  bool _isPasswordLogin = false;    // 当前是否为密码登录模式
  bool _obscurePassword = true;     // 密码是否脱敏显示

  // 验证码倒计时相关
  bool _isCodeSent = false;         // 验证码是否已发送
  int _countdownTime = 60;          // 倒计时秒数
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- 倒计时逻辑 ---
  void _startCountdown() {
    if (_phoneController.text.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("请输入正确的手机号")));
      return;
    }

    setState(() {
      _isCodeSent = true;
      _countdownTime = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownTime == 0) {
        // 倒计时结束
        setState(() {
          _isCodeSent = false;
        });
        timer.cancel();
      } else {
        setState(() {
          _countdownTime--;
        });
      }
    });

    // TODO: 这里调用发送短信的 API
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("验证码已发送: 123456")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 跳转到注册页
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterPage()),
              );
            },
            child: const Text("注册账户", style: TextStyle(color: Colors.black)),
          )
        ],
      ),
      // 使用 SingleChildScrollView 防止键盘遮挡
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // 1. 大标题
            const Text(
              "欢迎回来 👋",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 10),
            const Text(
              "登录以同步您的账单数据",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 40),

            // 2. 模式切换 (验证码登录 / 密码登录)
            Row(
              children: [
                _buildModeTab("验证码登录", !_isPasswordLogin),
                const SizedBox(width: 20),
                _buildModeTab("密码登录", _isPasswordLogin),
              ],
            ),

            const SizedBox(height: 30),

            // 3. 输入框区域
            Column(
              children: [
                // 3.1 手机号输入框 (通用)
                _buildInputContainer(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.phone_iphone, color: Colors.grey),
                      hintText: "请输入手机号",
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),

                const SizedBox(height: 16),

                // 3.2 动态输入框 (验证码 OR 密码)
                if (!_isPasswordLogin)
                // --- 验证码模式 ---
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputContainer(
                          child: TextField(
                            controller: _codeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.security, color: Colors.grey),
                              hintText: "请输入验证码",
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 发送验证码按钮
                      GestureDetector(
                        onTap: _isCodeSent ? null : _startCountdown,
                        child: Container(
                          width: 110,
                          height: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _isCodeSent ? Colors.grey[200] : Colors.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _isCodeSent ? "${_countdownTime}s" : "获取验证码",
                            style: TextStyle(
                              color: _isCodeSent ? Colors.grey : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                // --- 密码模式 ---
                  _buildInputContainer(
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword, // 是否隐藏密码
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                        hintText: "请输入登录密码",
                        hintStyle: const TextStyle(color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // 忘记密码 (仅在密码模式显示)
            if (_isPasswordLogin)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text("忘记密码?", style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              const SizedBox(height: 48), // 占位保持高度一致体验

            const SizedBox(height: 20),

            // 4. 登录大按钮
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 5,
                  shadowColor: Colors.black.withOpacity(0.3),
                ),
                child: const Text(
                  "登 录",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 5. 第三方登录 (微信、Apple、Google)
            Center(
              child: Column(
                children: [
                  const Text("— 其他登录方式 —", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(Icons.wechat, const Color(0xFF07C160)),
                      const SizedBox(width: 24),
                      _buildSocialButton(Icons.apple, Colors.black),
                      const SizedBox(width: 24),
                      // Google 按钮 (使用自定义图标模拟)
                      _buildSocialButton(null, Colors.red, isGoogle: true),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 6. 底部协议
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: _isAgreed,
                  activeColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  onChanged: (value) {
                    setState(() {
                      _isAgreed = value!;
                    });
                  },
                ),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      text: "我已阅读并同意 ",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                      children: [
                        TextSpan(
                          text: "《用户协议》",
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: " 和 "),
                        TextSpan(
                          text: "《隐私政策》",
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
    );
  }

  // --- 辅助组件 ---

  // 顶部 Tab 切换
  Widget _buildModeTab(String text, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isPasswordLogin = (text == "密码登录");
        });
      },
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.black : Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          if (isActive)
            Container(
              width: 20,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(2),
              ),
            )
        ],
      ),
    );
  }

  // 输入框容器样式
  Widget _buildInputContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7), // 浅灰背景
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  // 第三方登录圆形按钮
  Widget _buildSocialButton(IconData? icon, Color color, {bool isGoogle = false}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        color: Colors.white,
      ),
      alignment: Alignment.center,
      child: isGoogle
      // 模拟 Google 图标 (G字)
          ? const Text(
          "G",
          style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.red
          )
      )
          : Icon(icon, color: color, size: 26),
    );
  }

  // 处理登录
  void _handleLogin() {
    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("请先同意用户协议")));
      return;
    }

    if (_phoneController.text.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("手机号格式错误")));
      return;
    }

    if (!_isPasswordLogin) {
      // 验证码模式校验
      if (_codeController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("请输入验证码")));
        return;
      }
    } else {
      // 密码模式校验
      if (_passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("请输入密码")));
        return;
      }
    }

    // 登录成功，跳转首页
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainPage()),
    );
  }
}
