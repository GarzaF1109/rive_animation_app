import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;

  //Cerebro de la animación
  StateMachineController? _controller;
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSucces;
  SMITrigger? _trigFail;

  SMINumber? _numLook;

  Timer? _typingDebounce;

  //Crear variables para focusNode
  final _emailFocus = FocusNode();
  final _passwordsFocus = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _emailFocus.addListener(() {
      _isChecking?.change(_emailFocus.hasFocus);
      if (_emailFocus.hasFocus) {
        _isHandsUp?.change(false);
        _numLook?.value = 50;
      }
    });
    _passwordsFocus.addListener(() {
      _isHandsUp?.change(_passwordsFocus.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                width: size.width,
                height: 200,
                child: RiveAnimation.asset(
                  'assets/animated_login_bear.riv',

                  stateMachines: ['Login Machine'],
                  //Al iniciar la animación
                  onInit: (artboard) {
                    _controller = StateMachineController.fromArtboard(
                      artboard,
                      "Login Machine",
                    );
                    if (_controller == null) return;
                    artboard.addController(_controller!);
                    _isChecking = _controller!.findSMI('isChecking');
                    _isHandsUp = _controller!.findSMI('isHandsUp');
                    _trigSucces = _controller!.findSMI('trigSucces');
                    _trigFail = _controller!.findSMI('trigFail');
                    _numLook = _controller!.findSMI('numLook');
                  },
                ),
              ),
              SizedBox(height: 10),
              TextField(
                focusNode: _emailFocus,
                onChanged: (value) {
                  if (_isChecking == null) return;
                  _isChecking!.change(true);
                  final look = (value.length / 80.0 * 100.0).clamp(0.0, 100.0);
                  _numLook?.value = look;
                  _typingDebounce?.cancel();
                  _typingDebounce = Timer
                  (const Duration(seconds:3), (){
                    if (!mounted) return;
                    _isChecking?.change(false);
                  });
                },
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Email",
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                focusNode: _passwordsFocus,
                onChanged: (value) {
                  //if (_isChecking != null) {
                  //  _isChecking!.change(false);
                  //}
                  if (_isHandsUp == null) return;
                  _isHandsUp!.change(true);
                },
                obscureText: _obscureText,
                decoration: InputDecoration(
                  hintText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailFocus.dispose();
    _passwordsFocus.dispose();
    _typingDebounce?.cancel();
  }
}
