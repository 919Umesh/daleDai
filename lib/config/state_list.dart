import 'package:omspos/screen/booking/state/booking_state.dart';
import 'package:omspos/screen/home/state/home_state.dart';
import 'package:omspos/screen/index/state/index_state.dart';
import 'package:omspos/screen/login/state/login_state.dart';
import 'package:omspos/screen/map/state/map_state.dart';
import 'package:omspos/screen/profile/state/profile_state.dart';
import 'package:omspos/screen/properties/state/properties_state.dart';
import 'package:omspos/screen/room/state/room_state.dart';
import 'package:omspos/services/language/localization_state.dart';
import 'package:omspos/themes/theme_state.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../screen/splash/splash_state.dart';

List<SingleChildWidget> myStateList = [
  ChangeNotifierProvider(create: (_) => SplashState()),
  ChangeNotifierProvider(create: (_) => ThemeState()),
  ChangeNotifierProvider(create: (_) => LocalizationState()),
  ChangeNotifierProvider(create: (_) => LoginState()),
  ChangeNotifierProvider(create: (_) => HomeState()),
  ChangeNotifierProvider(create: (_) => IndexState()),
  ChangeNotifierProvider(create: (_) => ProfileState()),
  ChangeNotifierProvider(create: (_) => PropertiesState()),
  ChangeNotifierProvider(create: (_) => RoomState()),
  ChangeNotifierProvider(create: (_) => BookingState()),
  ChangeNotifierProvider(create: (_) => MapState()),
];
