import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:inspired_senior_care_app/bloc/profile/profile_bloc.dart';
import 'package:inspired_senior_care_app/globals.dart';

class MainBottomAppBar extends StatefulWidget {
  const MainBottomAppBar({Key? key}) : super(key: key);

  @override
  State<MainBottomAppBar> createState() => _BottomAppBarState();
}

class _BottomAppBarState extends State<MainBottomAppBar> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return Container();
        }
        if (state is ProfileLoaded) {
          if (state.user.type == 'manager') {
            return BottomNavigationBar(
                onTap: (index) {
                  setState(() {
                    Globals().index = index;
                    //  currentIndex = index;
                  });
                  switch (index) {
                    case 0:
                      {
                        context.goNamed('manager-categories');
                      }
                      break;

                    case 1:
                      {
                        context.goNamed('home');
                      }
                      break;

                    case 2:
                      {
                        context.goNamed('dashboard');
                      }
                      break;
                  }
                },
                currentIndex: Globals().getIndex,
                items: const [
                  BottomNavigationBarItem(
                      label: 'Categories',
                      icon: Icon(FontAwesomeIcons.layerGroup)),
                  BottomNavigationBarItem(
                      label: 'Home', icon: Icon(Icons.home)),
                  BottomNavigationBarItem(
                      label: 'Dashboard', icon: Icon(Icons.dashboard_rounded)),
                ]);
          }
          if (state.user.type == 'user') {
            return BottomNavigationBar(
                onTap: (index) {
                  setState(() {
                    Globals().index = index;
                    // currentIndex = index;
                  });
                  switch (index) {
                    case 0:
                      {
                        context.goNamed('categories');
                      }
                      break;

                    case 1:
                      {
                        context.goNamed('home');
                      }
                      break;

                    case 2:
                      {
                        context.goNamed('profile');
                      }
                      break;
                  }
                },
                currentIndex: Globals().getIndex,
                items: const [
                  BottomNavigationBarItem(
                      label: 'Categories',
                      icon: Icon(FontAwesomeIcons.compass)),
                  BottomNavigationBarItem(
                      label: 'Home', icon: Icon(FontAwesomeIcons.plus)),
                  BottomNavigationBarItem(
                      label: 'Profile', icon: Icon(Icons.person)),
                ]);
          }
        }
        return const Center(
          child: Text('Something Went Wrong..'),
        );
      },
    );
  }
}
