import 'package:get/get.dart';
import 'package:foap/helper/common_import.dart';
import 'package:geocoding/geocoding.dart';

import '../../../model/preference_model.dart';

class SetLocation extends StatefulWidget {
  const SetLocation({Key? key}) : super(key: key);

  @override
  State<SetLocation> createState() => _SetLocationState();
}

class _SetLocationState extends State<SetLocation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 60,
            width: 60,
            color: Theme.of(context).cardColor,
            child: ThemeIconWidget(ThemeIcon.location,
                size: 20,
                color: Theme.of(context).primaryColor),
          ).round(30),
          Text(
            LocalizationString.locationHeader,
            style: Theme.of(context)
                .textTheme
                .displaySmall!
                .copyWith(fontWeight: FontWeight.w600),
          ).paddingOnly(top: 40),
          Text(
            LocalizationString.locationSubHeader,
            style: Theme.of(context).textTheme.titleSmall,
          ).paddingOnly(top: 20),
          Center(
            child: SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width - 50,
                child: FilledButtonType1(
                    cornerRadius: 25,
                    text: LocalizationString.locationService,
                    onPress: () {
                      LocationManager().getLocation((location) async {
                        try {
                          List<Placemark> placemarks = await placemarkFromCoordinates(
                            location.latitude ?? 0.0,
                            location.longitude ?? 0.0,
                          );
                          if (placemarks.isNotEmpty) {
                            Placemark marker = placemarks[0];
                            getIt<AddPreferenceManager>().preferenceModel?.country = marker.country;
                            getIt<AddPreferenceManager>().preferenceModel?.city = marker.locality;
                          }
                        } catch(err) {

                        }
                      });
                      Get.to(() => const AllowNotification());
                    })),
          ).paddingOnly(top: 150),
        ],
      ).hP25,
    );
  }
}