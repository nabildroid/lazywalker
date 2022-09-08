import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazywalker/repositories/djezzy_auth.dart';
import 'package:lazywalker/repositories/local_db.dart';

import '../services/background.dart';

class SimState extends Equatable {
  final List<DjezzAuthenticatedPhoneNumber> authenticatedPhoneNumbers;

  final String stagedPhoneNumber;

  final bool loadingForAuthentication;

  const SimState(
    this.authenticatedPhoneNumbers,
    this.stagedPhoneNumber,
    this.loadingForAuthentication,
  );

  // copyWith
  SimState copyWith({
    List<DjezzAuthenticatedPhoneNumber>? authenticatedPhoneNumbers,
    String? stagedPhoneNumber,
    bool? loadingForAuthentication,
  }) {
    return SimState(
      authenticatedPhoneNumbers ?? this.authenticatedPhoneNumbers,
      stagedPhoneNumber ?? this.stagedPhoneNumber,
      loadingForAuthentication ?? this.loadingForAuthentication,
    );
  }

  // init
  factory SimState.init() {
    return const SimState([], "", false);
  }

  @override
  List<Object?> get props =>
      [authenticatedPhoneNumbers, stagedPhoneNumber, loadingForAuthentication];
}

class SimCubit extends Cubit<SimState> {
  final LocalDB _db;
  SimCubit(this._db) : super(SimState.init());

  init() async {
    final authenticatedPhoneNumbers = await _db.getPhoneNumbers();
    emit(state.copyWith(
      authenticatedPhoneNumbers: authenticatedPhoneNumbers,
    ));
  }

  sign(String phoneNumber) async {
    emit(state.copyWith(
      stagedPhoneNumber: phoneNumber,
      loadingForAuthentication: true,
    ));

    await DjezzyAuth.sign(phoneNumber);

    emit(state.copyWith(
      loadingForAuthentication: false,
    ));
  }

  Future<bool> verify(String otp) async {
    final auth = await DjezzyAuth.validateOtp(
      DjezzyOtpRequest(state.stagedPhoneNumber, otp),
    );
    if (auth == null) return false;

    final authenticatedPhoneNumber = DjezzAuthenticatedPhoneNumber(
      state.stagedPhoneNumber,
      token: auth.token,
      created: DateTime.now(),
    );

    await _db.addPhoneNumber(authenticatedPhoneNumber);

    emit(state.copyWith(
      authenticatedPhoneNumbers: [
        ...state.authenticatedPhoneNumbers,
        authenticatedPhoneNumber,
      ],
      loadingForAuthentication: false,
    ));

    return true;
  }

  addPhoneNumber(DjezzAuthenticatedPhoneNumber phoneNumber) async {
    await _db.addPhoneNumber(phoneNumber);

    final authenticatedPhoneNumbers = state.authenticatedPhoneNumbers;
    // CHECK probably you should create new array!
    authenticatedPhoneNumbers.add(phoneNumber);
    emit(state.copyWith(
      authenticatedPhoneNumbers: authenticatedPhoneNumbers,
    ));
  }
}
