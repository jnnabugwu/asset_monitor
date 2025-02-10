// import 'package:iot_asset_generator/iot_asset_generator.dart' as iot_asset_generator;
import 'package:iot_asset_generator/iot_asset_generator.dart';

void main() async {
  final generator = AssetDataGenerator();
  final assets = generator.generateAssetData(
    numAssets: 4,
    daysOfData: 7,
    readingsPerDay: 1,
  );

  await generator.saveToJson(assets, 'assets1.json');

  print('Generated ${assets.length} readings for ${assets.map((a) => a.id).toSet().length} assets');
  print('Data saved to asset_data.csv');

  // await convertToJsonl('assets.json');


}