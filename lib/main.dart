import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fic9_ecommerce/presentation/auth/bloc/login/login_bloc.dart';
import 'package:flutter_fic9_ecommerce/presentation/cart/bloc/cart/cart_bloc.dart';
import 'package:flutter_fic9_ecommerce/presentation/home/bloc/products/products_bloc.dart';

import 'data/datasources/auth_local_datasource.dart';
import 'presentation/auth/bloc/register/register_bloc.dart';
import 'presentation/auth/splash_page.dart';
import 'presentation/cart/bloc/order/order_bloc.dart';
import 'presentation/dashboard/dashboard_page.dart';
import 'presentation/payment/bloc/order_detail/order_detail_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => RegisterBloc(),
        ),
        BlocProvider(
          create: (context) => LoginBloc(),
        ),
        BlocProvider(
          create: (context) =>
              ProductsBloc()..add(const ProductsEvent.getAll()),
        ),
        BlocProvider(
          create: (context) => CartBloc(),
        ),
        BlocProvider(
          create: (context) => OrderBloc(),
        ),
        BlocProvider(
          create: (context) => OrderDetailBloc(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: FutureBuilder<bool>(
          future: AuthLocalDatasource().isLogin(),
          builder: (context, snapshot) {
            if (snapshot.data != null && snapshot.data!) {
              return const DashboardPage();
            } else {
              return const SplashPage();
            }
          },
        ),
      ),
    );
  }
}
