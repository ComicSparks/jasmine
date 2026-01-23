import 'package:flutter/material.dart';

class FloatingSearchBarScreen extends StatefulWidget {
  final FloatingSearchBarController controller;
  final Widget child;
  final ValueChanged<String>? onSubmitted;
  final String? hint;
  final bool showCursor;
  final bool autocorrect;
  final Widget? panel;

  const FloatingSearchBarScreen({
    required this.controller,
    required this.child,
    this.hint,
    this.showCursor = true,
    this.autocorrect = true,
    this.onSubmitted,
    this.panel,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FloatingSearchBarScreenState();
}

class _FloatingSearchBarScreenState extends State<FloatingSearchBarScreen>
    with SingleTickerProviderStateMixin {
  final _node = FocusNode();
  late final TextEditingController _textEditingController =
      TextEditingController();
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final _in = Tween(begin: 0.0, end: 1.0).animate(_animationController);

  @override
  void initState() {
    widget.controller._state = this;
    super.initState();
  }

  @override
  void dispose() {
    _node.dispose();
    _textEditingController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          ..._animationController.isDismissed
              ? []
              : [
                  _buildBackdrop(),
                  _buildSearchBar(),
                  _buildOnPop(),
                ],
        ],
      ),
    );
  }

  Widget _buildOnPop() {
    return WillPopScope(
      onWillPop: () async {
        if (_animationController.isDismissed) {
          return true;
        }
        _animationController.reverse();
        return false;
      },
      child: Container(),
    );
  }

  Widget _buildBackdrop() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return AnimatedBuilder(
          animation: _in,
          builder: (BuildContext context, Widget? child) {
            if (_in.value > 0) {
              return GestureDetector(
                onTap: () {
                  _hideSearchBar();
                },
                child: Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  color: Colors.black.withOpacity(.3 * _in.value),
                ),
              );
            }
            return Container();
          },
        );
      },
    );
  }

  Widget _buildSearchBar() {
    final mq = MediaQuery.of(context);
    double statusBarHeight = mq.padding.top;
    double finalHeight = 80 + statusBarHeight;
    return AnimatedBuilder(
      animation: _in,
      builder: (BuildContext context, Widget? child) {
        return Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: statusBarHeight),
              child: Transform.translate(
                offset: Offset(0, (_in.value * finalHeight) - finalHeight),
                child: Column(
                  children: [
                    _SearchBarContainer(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _hideSearchBar,
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Expanded(child: _buildTextField()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ...(widget.panel == null
                ? []
                : [
                    Expanded(
                      child: Transform.translate(
                        offset: Offset(
                          (_in.value * mq.size.width) - mq.size.width,
                          0,
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(
                            top: 5,
                            left: 10,
                            right: 10,
                            bottom: 15,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade500.withOpacity(.3),
                              width: .1,
                            ),
                            color: Theme.of(context).scaffoldBackgroundColor,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: .2,
                                spreadRadius: .3,
                                color: Colors.grey.shade500.withOpacity(.3),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: widget.panel,
                        ),
                      ),
                    ),
                  ]),
          ],
        );
      },
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: _textEditingController,
      showCursor: widget.showCursor,
      scrollPadding: EdgeInsets.zero,
      scrollPhysics: const NeverScrollableScrollPhysics(),
      focusNode: _node,
      maxLines: 1,
      autofocus: false,
      autocorrect: widget.autocorrect,
      //cursorColor: style.accentColor,
      //style: style.queryStyle,
      // textInputAction: widget.textInputAction,
      // keyboardType: widget.textInputType,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        isDense: true,
        hintText: widget.hint ?? "搜索",
        // hintStyle: style.hintStyle,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        errorBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        fillColor: Colors.transparent,
      ),
    );
  }

  void _displayFloatingSearchBar({String? modifyInput}) {
    if (modifyInput != null) {
      _textEditingController.text = modifyInput;
    }
    _node.requestFocus();
    _animationController.forward();
  }

  void _hideSearchBar() {
    _node.unfocus();
    _animationController.reverse();
  }
}

class _SearchBarContainer extends StatelessWidget {
  final Widget child;

  const _SearchBarContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 5, 8, 5),
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade500.withOpacity(.3),
          width: .1,
        ),
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            blurRadius: .2,
            spreadRadius: .3,
            color: Colors.grey.shade500.withOpacity(.3),
          ),
        ],
        borderRadius: BorderRadius.circular(5),
      ),
      child: child,
    );
  }
}

class FloatingSearchBarController {
  _FloatingSearchBarScreenState? _state;

  void hide() => _state?._hideSearchBar();

  void display({String? modifyInput}) =>
      _state?._displayFloatingSearchBar(modifyInput: modifyInput);
}
