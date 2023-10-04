import 'package:get/get.dart';

class DataWrapper {
  List<dynamic> items = [];
  int page = 1;
  RxBool haveMoreData = true.obs;
  RxBool isLoading = false.obs;
  RxInt totalRecords = 0.obs;

  DataWrapper();
}
