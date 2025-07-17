
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../screen/splash/splash_state.dart';


List<SingleChildWidget> myStateList = [
  ChangeNotifierProvider(create: (_) => SplashState()),
];