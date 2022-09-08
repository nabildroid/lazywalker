import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazywalker/cubes/sim_cubit.dart';
import 'package:lazywalker/widgets/sim_card.dart';

class AddSim extends StatelessWidget {
  AddSim({Key? key}) : super(key: key);

  final TextEditingController phone = TextEditingController(text: "798398545");
  final TextEditingController otp = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black26,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Center(
          child: BlocBuilder<SimCubit, SimState>(
              buildWhen: (previous, current) => true,
              builder: (context, state) {
                return AnimatedCrossFade(
                  duration: Duration(milliseconds: 300),
                  crossFadeState: state.stagedPhoneNumber.isNotEmpty &&
                          state.loadingForAuthentication == false
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: Container(
                    width: 300,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 167, 41, 41),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [],
                    ),
                    child: Column(children: [
                      Text("Enter your phone Number"),
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Phone Number",
                        ),
                        controller: phone,
                        onSubmitted: (_) {
                          context.read<SimCubit>().sign(phone.text);
                        },
                      ),
                    ]),
                  ),
                  secondChild: Container(
                    width: 300,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 84, 182, 28),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(children: [
                      Text("Enter OTP"),
                      TextField(
                        decoration: InputDecoration(
                          hintText: "*****",
                        ),
                        controller: otp,
                        onSubmitted: (_) {
                          context
                              .read<SimCubit>()
                              .verify(otp.text)
                              .then((value) {
                            // todo antipattern

                            if (value) {
                              Navigator.of(context).pop();
                            } else {
                              otp.text = "";
                            }
                          });
                        },
                      ),
                    ]),
                  ),
                );
              }),
        ),
      ),
    );
  }
}
