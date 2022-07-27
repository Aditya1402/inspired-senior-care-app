part of 'onboarding_bloc.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object> get props => [];
}

class CompletedPage extends OnboardingEvent {}

class NextPage extends OnboardingEvent {}

class StartOnboarding extends OnboardingEvent {
  final User user;

  const StartOnboarding({
    this.user = const User(
        name: '', emailAddress: '', type: null, title: '', userColor: null),
  });

  @override
  // TODO: implement props
  List<Object> get props => [user];
}

class UpdateUser extends OnboardingEvent {
  final User? user;

  const UpdateUser({this.user});

  @override
  // TODO: implement props
  List<Object> get props => [user!];
}
