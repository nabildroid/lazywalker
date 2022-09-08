import 'package:flutter/material.dart';
import 'package:lazywalker/cubes/setting_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazywalker/cubes/sim_cubit.dart';
import 'package:lazywalker/cubes/walks_cubit.dart';
import 'package:lazywalker/main.dart';
import 'package:lazywalker/models/djezzy_walk_offer.dart';
import 'package:lazywalker/screens/add_sim.dart';

import '../services/background.dart';
import '../widgets/appbar_title.dart';
import '../widgets/expandable_top_section.dart';
import '../widgets/inline_toggle.dart';
import '../widgets/sim_card.dart';
import '../widgets/vertical_setting_parameter.dart';

class Home1 extends StatefulWidget {
  Home1({Key? key}) : super(key: key);

  @override
  State<Home1> createState() => _Home1State();
}

class _Home1State extends State<Home1> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [AppbarTitle()],
        ),
        actions: [
          IconButton(
            onPressed: context.read<SettingCubit>().reset,
            icon: Icon(Icons.logout_outlined),
          )
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: ExpandableTopSection(
        maxRatio: .55,
        minRatio: .35,
        topSection: Container(
          padding: EdgeInsets.only(top: AppBar().preferredSize.height),
          decoration: BoxDecoration(
            color: Colors.purple.shade600,
            borderRadius:
                BorderRadius.vertical(bottom: Radius.elliptical(40, 30)),
          ),
          child: Column(children: [
            SizedBox(
              height: 150,
              child: BlocBuilder<SimCubit, SimState>(
                builder: (context, state) {
                  final phones = state.authenticatedPhoneNumbers;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (ctx, i) {
                      if (i == phones.length) {
                        return SimCard.template(
                            onTap: () => {
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: ((context, animation,
                                              secondaryAnimation) =>
                                          AddSim()),
                                      opaque: false,
                                    ),
                                  )
                                });
                      }
                      return SimCard(
                        phoneNumber: phones[i].phoneNumber,
                        time: phones[i].created,
                        onTap: () => {},
                      );
                    },
                    itemCount: phones.length + 1,
                  );
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                BlocBuilder<SettingCubit, SettingState>(
                    builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VerticalSettingParamter(
                        label: "Interval",
                        value: state.appSetting.interval,
                        icon: Icons.short_text_sharp,
                        max: 30,
                        min: 2,
                        onChange: (v) =>
                            context.read<SettingCubit>().setInterval(v),
                        step: 1,
                        sefix: "days",
                      ),
                      VerticalSettingParamter(
                        label: "Time",
                        value: state.appSetting.time.hour,
                        icon: Icons.timer,
                        max: 23,
                        min: 0,
                        onChange: (v) => context
                            .read<SettingCubit>()
                            .setTime(TimeOfDay(hour: v, minute: 0)),
                        step: 1,
                        sefix: state.appSetting.time.period == DayPeriod.am
                            ? "AM"
                            : "PM",
                      ),
                      VerticalSettingParamter(
                        label: "Repetition",
                        value: state.appSetting.repetition,
                        icon: Icons.repeat,
                        max: 10,
                        min: 1,
                        onChange: (v) =>
                            context.read<SettingCubit>().setRepetition(v),
                        step: 1,
                        sefix: "times",
                      ),
                    ],
                  );
                }),
                Spacer(),
                BlocBuilder<SettingCubit, SettingState>(
                    builder: (context, state) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InlineToggle(
                        isSelected: state.appSetting.offers
                            .contains(DjezzyWalkOfferOptions.g1),
                        label: "1 GB",
                        select: () => context
                            .read<SettingCubit>()
                            .toggleOffer(DjezzyWalkOfferOptions.g1),
                      ),
                      InlineToggle(
                        isSelected: state.appSetting.offers
                            .contains(DjezzyWalkOfferOptions.g2),
                        label: "2 GB",
                        select: () => context
                            .read<SettingCubit>()
                            .toggleOffer(DjezzyWalkOfferOptions.g2),
                      ),
                      InlineToggle(
                        isSelected: state.appSetting.offers
                            .contains(DjezzyWalkOfferOptions.g4),
                        label: "4 GB",
                        select: () => context
                            .read<SettingCubit>()
                            .toggleOffer(DjezzyWalkOfferOptions.g4),
                      ),
                      InlineToggle(
                        isSelected: state.appSetting.offers
                            .contains(DjezzyWalkOfferOptions.g6),
                        label: "6 GB",
                        select: () => context
                            .read<SettingCubit>()
                            .toggleOffer(DjezzyWalkOfferOptions.g6),
                      ),
                    ],
                  );
                })
              ],
            )
          ]),
        ),
        bottomSection: Column(
          children: [
            Expanded(child:
                BlocBuilder<WalksCubit, WalksState>(builder: (context, state) {
              return SizedBox(
                height: 200,
                child: ListView.builder(
                  itemBuilder: (ctx, i) {
                    return ListTile(
                      leading: Icon(
                        state.walks[i].isSuccessful
                            ? Icons.check_circle
                            : Icons.error,
                      ),
                      title: Text(state.walks[i].offer.code),
                      subtitle: Text(state.walks[i].time.toString()),
                      trailing: Text("${state.walks[i].duration.inSeconds}s"),
                    );
                  },
                  itemCount: state.walks.length,
                  reverse: true,
                ),
              );
            })),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  BlocBuilder<SettingCubit, SettingState>(
                      builder: (context, state) {
                    return TextButton.icon(
                      onPressed: () {
                        if (state.appSetting.enabled)
                          context.read<SettingCubit>().disable();
                        else
                          context.read<SettingCubit>().enable();
                      },
                      icon: state.appSetting.enabled
                          ? const Icon(Icons.update_disabled_outlined)
                          : const Icon(Icons.slow_motion_video_sharp),
                      label:
                          Text(state.appSetting.enabled ? "Running" : "Paused"),
                    );
                  }),
                  Spacer(),
                  FloatingActionButton(
                    onPressed: () {
                      djezzyBackgroundTask(
                        ignoreDelay: true,
                        localNotification: flutterLocalNotificationsPlugin,
                      );
                    },
                    child: Icon(Icons.play_arrow_rounded),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
