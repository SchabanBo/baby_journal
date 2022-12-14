import 'package:baby_journal/helpers/locator.dart';
import 'package:baby_journal/models/child.dart';
import 'package:baby_journal/models/memory.dart';
import 'package:baby_journal/pages/home/settings/service.dart';
import 'package:overlayment/overlayment.dart';
import 'package:qlevar_router/qlevar_router.dart';
import 'package:reactable/reactable.dart';

import '../../services/storage_service.dart';
import 'memory/service.dart';

class HomeController extends BaseController {
  static HomeController get instance => locator<HomeController>();
  final child = Reactable<Child?>(null);
  final _service = locator<MemoriesService>();
  @override
  Future<void> onInit() async {
    final id = locator<StorageService>().getInt(StorageKeys.selectedChild);
    if (id == null) {
      QR.to('/home/settings');
      return;
    }
    child.value = await SettingsService().getChild(id);
  }

  void addMemory() {
    if (child.value == null) {
      Overlayment.showMessage('Please select a child');
      return;
    }
    QR.to('/memory/add');
  }

  Future<List<Memory>> getRandom() {
    return _service.getRandom(child.value!.id);
  }

  Future<List<Memory>> getLast() async {
    final result = await _service.getAll(child.value!.id, 0, 10);
    return result?.records ?? [];
  }
}
