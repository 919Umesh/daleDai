import 'package:flutter/widgets.dart';
import 'package:omspos/screen/home/api/home_api.dart';
import 'package:omspos/screen/home/model/home_model.dart';
import 'package:omspos/utils/custom_log.dart';

class HomeState extends ChangeNotifier {
  HomeState();

  BuildContext? _context;
  BuildContext? get context => _context;
  
  set getContext(BuildContext value) {
    _context = value;
    initialize();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  List<AreaModel> _areas = [];
  List<AreaModel> get areas => _areas;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    await clean();
    await loadAllAreas();
  }

  Future<void> clean() async {
    _isLoading = false;
    _errorMessage = null;
    _areas = [];
    notifyListeners();
  }

  Future<void> loadAllAreas() async {
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      _areas = await HomeApi.getAllAreas();
      _errorMessage = null;
      CustomLog.successLog(value: 'Loaded ${_areas.length} areas');
    } catch (e) {
      _errorMessage = e.toString();
      _areas = [];
      CustomLog.errorLog(value: 'Areas load error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAreas() async {
    await loadAllAreas();
  }
}