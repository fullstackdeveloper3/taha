import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../redux/app/app_state.dart';
import '../../redux/sign_up/sign_up_actions.dart';
import '../common/loading_view.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _controller = TextEditingController();
  String _name = '';

  bool get _canRegister => _name.length >= 3 && _name.length <= 16;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SignUpState>(
      converter: (store) => store.state.signUpState,
      builder: (context, signUpState) {
        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    padding: EdgeInsets.only(
                        top: constraints.maxHeight / 4,
                        left: 24,
                        right: 24,
                        bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(
                          child: Text(
                            'Fire Todo',
                            style: TextStyle(
                                fontSize: 34, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 44),
                        TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'Enter your name...',
                          ),
                          onChanged: (value) => setState(() => _name = value),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Opacity(
                            opacity: _canRegister ? 1.0 : 0.5,
                            child: OutlinedButton(
                              onPressed: _canRegister
                                  ? () => StoreProvider.of<AppState>(context)
                                      .dispatch(signUp(_name))
                                  : null,
                              style: OutlinedButton.styleFrom(
                                shape: const StadiumBorder(),
                                side: BorderSide(
                                    color: _canRegister
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                        : Colors.grey,
                                    width: 2),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 12),
                              ),
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                LoadingView(isLoading: signUpState.requesting),
              ],
            ),
          ),
        );
      },
    );
  }
}
