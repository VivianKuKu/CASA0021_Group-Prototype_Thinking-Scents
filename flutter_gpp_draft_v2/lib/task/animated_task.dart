import 'package:flutter/material.dart';
import 'task_complete_ring.dart';

class AnimatedTask extends StatefulWidget {
  const AnimatedTask({Key? key}) : super(key: key);

  @override
  _AnimatedTaskState createState() => _AnimatedTaskState();
}

class _AnimatedTaskState extends State<AnimatedTask> with SingleTickerProviderStateMixin{
  late final AnimationController _animationController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration:  Duration(milliseconds: 500),
    );
    _animationController.value;
    _animationController.forward();
    // // _animationController.reverse();
    // _animationController.addListener(() {
    //   print('value: ${_animationController.value}');
    // });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (BuildContext context, Widget? child) {
        return TaskCompleteRing(
          progress: _animationController.value,
        );
      },
    );
  }
}
