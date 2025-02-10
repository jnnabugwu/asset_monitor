import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:asset_monitor/features/asset_monitoring/data/models/asset_model.dart';
import 'package:asset_monitor/core/errors/exception.dart';

abstract class AssetOpenAIRemoteDataSource {
  Future<List<AssetModel>> getAssets();
  Future<AssetModel> getAsset(String id);
}

class AssetOpenAIRemoteDataSourceImpl implements AssetOpenAIRemoteDataSource {
  final http.Client client;
  final String fileId;
  final String openAIKey;
  final String baseUrl = 'https://api.openai.com/v1/files';

  AssetOpenAIRemoteDataSourceImpl({
    required this.client,
    required this.fileId,
    required this.openAIKey,
  });

  @override
Future<List<AssetModel>> getAssets() async {
  try {
    final response = await client.get(
      Uri.parse('$baseUrl/$fileId/content'),
      headers: {
        'Authorization': 'Bearer $openAIKey',
        'Content-Type': 'application/json',
      },
    );  
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final assetsList = jsonData['assets'] as List;
      return assetsList.map((json) => AssetModel.fromJson(json)).toList();
    } else {
      throw ServerException(
        message: 'Failed to fetch assets from OpenAI',
        statusCode: response.statusCode.toString(),
      );
    }
  } catch (e, stackTrace) {
    print('Error: $e\nStack trace: $stackTrace');
    throw ServerException(
      message: e.toString(),
      statusCode: 'FETCH_FAILED',
    );
  }
}

  @override
  Future<AssetModel> getAsset(String id) async {
    try {
      final assets = await getAssets();
      final asset = assets.firstWhere(
        (asset) => asset.id == id,
        orElse: () => throw ServerException(
          message: 'Asset not found',
          statusCode: 'ASSET_NOT_FOUND',
        ),
      );
      return asset;
    } catch (e) {
      throw ServerException(
        message: e.toString(),
        statusCode: 'FETCH_FAILED',
      );
    }
  }
}