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
import '../widgets/quick_settings.dart';
import '../widgets/sim_card.dart';
import '../widgets/sim_list.dart';
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
        maxRatio: .8,
        minRatio: .4,
        topSection: QuitSettings(),
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
