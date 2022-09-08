import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lazywalker/repositories/local_db.dart';

import '../models/walk.dart';

class WalksState extends Equatable {
  final List<Walk> walks;

  const WalksState({
    required this.walks,
  });

  double get failedWalksPersentage {
    final failedWalks = walks.where((walk) => !walk.isSuccessful).length;
    return failedWalks / walks.length;
  }

  WalksState copyWith({
    List<Walk>? walks,
  }) {
    return WalksState(
      walks: walks ?? this.walks,
    );
  }

  @override
  List<Object?> get props => [walks];

  factory WalksState.initial() {
    return const WalksState(
      walks: [],
    );
  }
}

class WalksCubit extends Cubit<WalksState> {
  final LocalDB db;
  WalksCubit(this.db) : super(WalksState.initial());

  void addWalk(Walk walk) {
    throw Exception('Only Background Process can add walks');
  }

  init() async {
    final walks = await db.getWalks();
    emit(state.copyWith(walks: walks));
  }
}
