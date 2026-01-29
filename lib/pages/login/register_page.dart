import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // 控制器
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 状态变量
  bool _obscurePassword = true;        // 密码是否隐藏
  bool _isCodeSent = false;            // 验证码是否已发送
  int _countdownTime = 60;             // 倒计时
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

    // 模拟发送
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("验证码已发送: 8888")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("注册新账户", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "开启您的智能记账之旅",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "只需几步，轻松管理您的财务",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // 1. 手机号
            _buildLabel("手机号"),
            _buildInputContainer(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "请输入 11 位手机号",
                  hintStyle: TextStyle(color: Colors.grey),
                  icon: Icon(Icons.phone_iphone, color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. 验证码
            _buildLabel("验证码"),
            Row(
              children: [
                Expanded(
                  child: _buildInputContainer(
                    child: TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "4 位验证码",
                        hintStyle: TextStyle(color: Colors.grey),
                        icon: Icon(Icons.security, color: Colors.black87),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _isCodeSent ? null : _startCountdown,
                  child: Container(
                    width: 110,
                    height: 52, // 高度与输入框一致
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
            ),
            const SizedBox(height: 20),

            // 3. 设置密码 (已移除确认密码)
            _buildLabel("设置密码"),
            _buildInputContainer(
              child: TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "8-20 位字母与数字组合",
                  hintStyle: const TextStyle(color: Colors.grey),
                  icon: const Icon(Icons.lock_outline, color: Colors.black87),
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

            const SizedBox(height: 50),

            // 4. 注册按钮
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700), // 使用金色
                  foregroundColor: Colors.black, // 文字黑色
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 5,
                  shadowColor: Colors.orange.withOpacity(0.3),
                ),
                child: const Text(
                  "立即注册",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Center(
              child: Text(
                "注册即代表同意《用户协议》与《隐私政策》",
                style: TextStyle(color: Colors.grey[400], fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 辅助方法 ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildInputContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7), // 这里是原来那个经典的浅灰背景
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: child,
    );
  }

  void _handleRegister() {
    final phone = _phoneController.text;
    final code = _codeController.text;
    final pwd = _passwordController.text;

    // 简单校验
    if (phone.length != 11) {
      _showMsg("手机号格式错误");
      return;
    }
    if (code.isEmpty) {
      _showMsg("请输入验证码");
      return;
    }
    if (pwd.length < 6) {
      _showMsg("密码太短，请至少设置6位");
      return;
    }

    // 模拟注册成功
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("注册成功！请登录")),
    );

    // 注册成功后，返回登录页，并带回手机号
    Navigator.pop(context, phone);
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
