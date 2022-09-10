import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazywalker/models/app_settings.dart';
import 'package:lazywalker/widgets/sim_list.dart';
import 'package:lazywalker/widgets/vertical_setting_parameter.dart';

import '../cubes/setting_cubit.dart';
import '../models/djezzy_walk_offer.dart';
import 'inline_toggle.dart';

class QuitSettings extends StatelessWidget {
  const QuitSettings({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      final isSmall = constrains.maxHeight < 400;

      return Container(
        padding: EdgeInsets.only(top: AppBar().preferredSize.height * 1.7),
        decoration: const BoxDecoration(
          color: Color(0xff1c2765),
          borderRadius:
              BorderRadius.vertical(bottom: Radius.elliptical(40, 30)),
        ),
        child: Column(children: [
          SimList(),
          const SizedBox(
            height: 40,
          ),
          BlocBuilder<SettingCubit, SettingState>(
            builder: (context, state) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FittedBox(
                      child: VerticalSettings(settings: state.appSetting)),
                  Toggles(settings: state.appSetting),
                ],
              ),
            ),
          ),
        ]),
      );
    });
  }
}

class VerticalSettings extends StatelessWidget {
  final AppSetting settings;
  const VerticalSettings({
    Key? key,
    required this.settings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      key: ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VerticalSettingParamter(
          label: "Interval",
          value: settings.interval,
          icon: Icons.short_text_sharp,
          max: 30,
          min: 2,
          onChange: (v) => context.read<SettingCubit>().setInterval(v),
          step: 1,
          sefix: "days",
        ),
        const SizedBox(height: 16),
        VerticalSettingParamter(
          label: "Time",
          value: settings.time.hour,
          icon: Icons.timer,
          max: 23,
          min: 0,
          onChange: (v) => context
              .read<SettingCubit>()
              .setTime(TimeOfDay(hour: v, minute: 0)),
          step: 1,
          sefix: settings.time.period == DayPeriod.am ? "AM" : "PM",
        ),
        const SizedBox(height: 16),
        VerticalSettingParamter(
          label: "Repetition",
          value: settings.repetition,
          icon: Icons.repeat,
          max: 10,
          min: 1,
          onChange: (v) => context.read<SettingCubit>().setRepetition(v),
          step: 1,
          sefix: "times",
        ),
      ],
    );
  }
}

class Toggles extends StatelessWidget {
  final AppSetting settings;
  const Toggles({
    Key? key,
    required this.settings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InlineToggle(
          isSelected: settings.offers.contains(DjezzyWalkOfferOptions.g1),
          label: "1 GB",
          select: () => context
              .read<SettingCubit>()
              .toggleOffer(DjezzyWalkOfferOptions.g1),
        ),
        const SizedBox(height: 20),
        InlineToggle(
          isSelected: settings.offers.contains(DjezzyWalkOfferOptions.g2),
          label: "2 GB",
          select: () => context
              .read<SettingCubit>()
              .toggleOffer(DjezzyWalkOfferOptions.g2),
        ),
        const SizedBox(height: 20),
        InlineToggle(
          isSelected: settings.offers.contains(DjezzyWalkOfferOptions.g4),
          label: "4 GB",
          select: () => context
              .read<SettingCubit>()
              .toggleOffer(DjezzyWalkOfferOptions.g4),
        ),
        const SizedBox(height: 20),
        InlineToggle(
          isSelected: settings.offers.contains(DjezzyWalkOfferOptions.g6),
          label: "6 GB",
          select: () => context
              .read<SettingCubit>()
              .toggleOffer(DjezzyWalkOfferOptions.g6),
        ),
      ],
    );
  }
}
