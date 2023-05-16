import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../utils/route_name.dart';
import '../../widgets/button.dart';
import 'pl_cubit.dart';
import 'screen_with_menu.dart';

class PfScreen extends StatelessWidget {
  PfScreen({PlCubit? cubit, super.key}) : _cubit = cubit ?? Modular.get<PlCubit>();

  final PlCubit _cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit..init(),
      child: const PlView(),
    );
  }
}

class PlView extends StatelessWidget {
  const PlView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlCubit, PlState>(
      builder: (_, state) {
        return ScreenWithMenu(RouteName.pf, contents: [
          if (state is PlInitial) const Center(child: CircularProgressIndicator()),
          if (state is PlLoaded)
            ...state.users.map((user) {
              return Button.label('user $user', onTap: () => Modular.to.pushNamed(RouteName.pl.path.replaceAll(':id', user)));
            })
        ]);
      },
    );
  }
}
