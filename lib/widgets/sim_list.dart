import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazywalker/cubes/sim_cubit.dart';
import 'package:lazywalker/widgets/sim_card.dart';

import '../screens/add_sim.dart';

class SimList extends StatefulWidget {
  SimList({Key? key}) : super(key: key);

  @override
  State<SimList> createState() => _SimListState();
}

class _SimListState extends State<SimList> {
  late final PageController _controller;

  double currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: .7);

    _controller.addListener(() {
      setState(() {
        currentPage = _controller.page ?? 0;
      });
    });
  }

  handleNewSimClick() {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: ((context, animation, secondaryAnimation) => AddSim()),
      opaque: false,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final max = 10;
    return SizedBox(
      height: 150,
      child: BlocBuilder<SimCubit, SimState>(
        builder: (context, state) {
          final phones = state.authenticatedPhoneNumbers;
          return PageView.builder(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            itemBuilder: (ctx, i) => AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: EdgeInsets.all(
                    Curves.bounceIn.transform(
                          (1 - _getScaleFactor(i, currentPage)),
                        ) *
                        20,
                  ),
                  child: child,
                );
              },
              child: i == phones.length
                  ? SimCard.template(onTap: handleNewSimClick)
                  : SimCard(
                      phoneNumber: phones[i].phoneNumber,
                      time: phones[0].created,
                      onTap: () => {},
                    ),
            ),
            itemCount: phones.length + 1,
          );
        },
      ),
    );
  }
}

double _getScaleFactor(int index, double currentPage) {
  return 1 - min(1, (index.toDouble() - currentPage).abs());
}
