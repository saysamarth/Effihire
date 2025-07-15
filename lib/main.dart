import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './app/payment/cubit/payment_cubit.dart';
import './app/payment/services/payment_services.dart';
import './app/payment/views/payment.dart';
import './config/service/shared_pref.dart';
import 'auth/Fetch Location/Location Cubit/location_cubit.dart';
import 'auth/Fetch Location/Location Cubit/location_service.dart';
import 'config/routes/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SharedPrefsService.init();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LocationCubit(LocationService())),
        BlocProvider(
          create: (context) => PaymentCubit(PaymentService()),
          child: PaymentTab(),
        ),
      ],
      child: MaterialApp.router(
        title: 'EffiHire',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          fontFamily: 'Roboto',
        ),
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
