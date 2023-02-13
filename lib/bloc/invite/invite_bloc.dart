import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:inspired_senior_care_app/bloc/auth/auth_bloc.dart';
import 'package:inspired_senior_care_app/bloc/profile/profile_bloc.dart';
import 'package:inspired_senior_care_app/data/models/group.dart';
import 'package:inspired_senior_care_app/data/models/invite.dart';
import 'package:inspired_senior_care_app/data/models/user.dart';
import 'package:inspired_senior_care_app/data/repositories/auth/auth_repository.dart';
import 'package:inspired_senior_care_app/data/repositories/database/database_repository.dart';
import 'package:meta/meta.dart';

part 'invite_event.dart';
part 'invite_state.dart';

class InviteBloc extends Bloc<InviteEvent, InviteState> {
  final DatabaseRepository _databaseRepository;
  final AuthRepository _authRepository;
  final AuthBloc _authBloc;
  final ProfileBloc _profileBloc;
  StreamSubscription<List<Invite>?>? inviteStream;
  StreamSubscription? authStream;

  InviteBloc({
    required DatabaseRepository databaseRepository,
    required AuthRepository authRepository,
    required AuthBloc authBloc,
    required ProfileBloc profileBloc,
  })  : _databaseRepository = databaseRepository,
        _authRepository = authRepository,
        _profileBloc = profileBloc,
        _authBloc = authBloc,
        super(InviteState.loading()) {
    authStream = _authBloc.stream.listen((state) {
      if (state.authStatus == AuthStatus.authenticated) {
        // add(LoadInvites());
        inviteStream = _databaseRepository.listenForInvites()!.listen((event) {
          if (event != null) {
            add(LoadInvites());
          }
        });
      }
    });

    on<InviteEvent>((event, emit) async {
      List<Invite> invites = [];
      if (event is LoadInvites) {
        invites.clear();
        _databaseRepository.getInvites()!.listen((event) {
          if (event != null) {
            invites.addAll(event);
          }
        });
        _databaseRepository.getSentInvites()!.listen((event) {
          if (event != null) {
            invites.addAll(event);
          }
        });
        emit(InviteState.loaded(invites));
      }
      if (event is MemberInviteSent) {
        emit(InviteState.sending());
        // Query User
        // If Users exists ? Add User to Group : Alert message.
        User? invitedUser;
        Invite? invite;
        _databaseRepository
            .getUserByEmail(event.emailAddress)
            .listen((user) async {
          if (user != null) {
            invitedUser = user;
            var currentUser = _profileBloc.state.user;
            invite = Invite(
                inviterName: currentUser.name!,
                groupName: event.group.groupName!,
                groupId: event.group.groupId!,
                inviterId: currentUser.id!,
                invitedUserId: user.id!,
                invitedUserName: user.name!,
                inviteType: 'member',
                status: 'sent');
          }
        });
        await Future.delayed(const Duration(seconds: 1));
        if (invitedUser != null) {
          await _databaseRepository.inviteMemberToGroup(invite!);
          emit(InviteState.sent());
          await Future.delayed(const Duration(seconds: 2));
          add(LoadInvites());
        } else {
          emit(InviteState.failed());
          await Future.delayed(const Duration(seconds: 2));
          add(LoadInvites());
        }
      }
      if (event is ManagerInviteSent) {
        emit(InviteState.sending());
        // Query User
        // If Users exists ? Add User to Group : Alert message.

        await emit.forEach(
          _databaseRepository.getUserByEmail(event.emailAddress),
          onData: (User? user) {
            var currentUser = _profileBloc.state.user;
            Invite invite = Invite(
                inviterName: currentUser.name!,
                groupName: event.group.groupName!,
                groupId: event.group.groupId!,
                inviterId: currentUser.id!,
                invitedUserName: currentUser.name!,
                invitedUserId: user!.id!,
                inviteType: 'manager',
                status: 'sent');
            if (user != null) {
              _databaseRepository.inviteMemberToGroup(invite);
              return InviteState.sent();
            } else {
              return InviteState.failed();
            }
          },
          onError: (error, stackTrace) {
            return InviteState.failed();
          },
        );
        await Future.delayed(const Duration(seconds: 3));
        emit(InviteState.initial());
      }
      if (event is InviteAccepted) {
        event.invite.inviteType == 'member'
            ? _databaseRepository.addMemberToGroup(
                event.invite.invitedUserId, event.invite.groupId, event.invite)
            : _databaseRepository.addManagerToGroup(
                event.invite.invitedUserId, event.invite.groupId, event.invite);
        emit(InviteState.accepted());
        await _databaseRepository.deleteInvite(event.invite);
        Invite acceptedInvite = event.invite.copyWith(
            status: 'accepted',
            inviterId: event.invite.invitedUserId,
            invitedUserId: event.invite.inviterId,
            inviterName: event.invite.invitedUserName,
            invitedUserName: event.invite.inviterName);
        await _databaseRepository.inviteMemberToGroup(acceptedInvite);
        await Future.delayed(const Duration(seconds: 2));
        add(LoadInvites());
      }
      if (event is InviteCancelled) {
        emit(InviteState.cancelled());
      }
      if (event is InviteReceived) {
        emit(InviteState.receieved());
      }
      if (event is InviteDeleted) {
        await _databaseRepository.deleteInvite(event.invite);
        add(LoadInvites());
      }
      if (event is InviteDenied) {
        await _databaseRepository.deleteInvite(event.invite);
        emit(InviteState.denied());
        Invite declinedInvite = event.invite.copyWith(
            status: 'declined',
            inviterId: event.invite.invitedUserId,
            invitedUserId: event.invite.inviterId,
            inviterName: event.invite.invitedUserName,
            invitedUserName: event.invite.inviterName);
        await _databaseRepository.inviteMemberToGroup(declinedInvite);
        await Future.delayed(const Duration(seconds: 2));
        add(LoadInvites());
      }
    });
  }
  @override
  Future<void> close() async {
    await authStream?.cancel();
    await inviteStream?.cancel();
    return super.close();
  }
}
