import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:inspired_senior_care_app/bloc/profile/profile_bloc.dart';
import 'package:inspired_senior_care_app/cubits/login/login_cubit.dart';
import 'package:inspired_senior_care_app/view/widget/name_plate.dart';

class MainAppDrawer extends StatelessWidget {
  const MainAppDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(builder: (context, state) {
      if (state is ProfileLoaded) {
        return Drawer(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DrawerHeader(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Wrap(
                        // alignment: WrapAlignment.start,
                        spacing: 24.0,
                        children: [
                          SizedBox(
                            child: InitialsIcon(
                                userColor: hexToColor(state.user.userColor!),
                                memberName: state.user.name!),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                            child: Text(
                              state.user.name!.split(' ')[0],
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 20
                              ),
                            ),
                          ),
                        ],
                      )),
                  Column(
                    children: [
                      ListTile(
                        onTap: () {
                          context.pushNamed('settings');
                        },
                        title: Text(
                          'Settings',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                      ),
                      ListTile(
                        onTap: () {
                          context.pushNamed('subscriptions');
                        },
                        title: Text(
                          'My Subscriptions',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                      ),
                    ],
                  ),
                  const Divider(),
                  TextButton.icon(
                      onPressed: () {
                        context.read<LoginCubit>().signOut();
                      },
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Logout'))
                ]),
          ),
        );
      } else {
        return const Center(
          child: Text('Error Fetching Profile.'),
        );
      }
    });
  }
}
