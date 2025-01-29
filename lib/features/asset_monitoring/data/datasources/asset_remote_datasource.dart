
import 'dart:convert';

import 'package:asset_monitor/core/errors/exception.dart';
import 'package:asset_monitor/features/asset_monitoring/data/models/asset_model.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

abstract class AssetRemoteDataSource {
  Future<AssetModel> getAsset(String id);
  Stream<AssetModel> watchAssetUpdates(String id);
  Future<List<AssetModel>> getAssets();
  Future<void> updateAsset(AssetModel asset);
  Future<void> connect();
}

class AssetRemoteDataSourceImpl implements AssetRemoteDataSource {
  final MqttServerClient client;
  final Map<String, AssetModel> _latestAssets = {};

  AssetRemoteDataSourceImpl({
    required String endpoint,
    String? clientId,
  }) : client = MqttServerClient(
          endpoint,
          clientId ?? 'asset_monitor_${DateTime.now().millisecondsSinceEpoch}'
        ) {
    _setupClient();
  }

  void _setupClient() {
    client
      ..keepAlivePeriod = 20
      ..port = 8883
      ..secure = true
      ..onConnected = _onConnected
      ..onDisconnected = _onDisconnected
      ..onSubscribed = _onSubscribed;
  }

  void _onConnected() {
    print('Connected to AWS IoT Core');
  }

  void _onDisconnected() {
    print('Disconnected from AWS IoT Core');
  }

  void _onSubscribed(String topic) {
    print('Subscribed to $topic');
  }

  @override
  Future<void> connect() async {
    try {
      await client.connect();
      client.subscribe('+/data', MqttQos.atLeastOnce);
      
      client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
        for (var message in messages) {
          final payload = (message.payload as MqttPublishMessage).payload.message;
          final data = json.decode(String.fromCharCodes(payload));
          final asset = AssetModel.fromJson(data);
          _latestAssets[asset.id] = asset;
        }
      });
    } catch (e) {
      throw const ServerException(
        message: 'Failed to connect to MQTT server',
        statusCode: 'CONNECTION_FAILED'        
      );
    }
  }

  @override
  Future<AssetModel> getAsset(String id) async {
    try {
      if (_latestAssets.containsKey(id)) {
        return _latestAssets[id]!;
      }
      throw const ServerException(
        message: 'Asset not found',
        statusCode: 'ASSET_NOT_FOUND'        
      );
    } catch (e) {
      throw const ServerException(
        message: 'Failed to get asset',
        statusCode: 'GET_ASSET_FAILED'
      );
    }
  }

  @override
  Stream<AssetModel> watchAssetUpdates(String id) async* {
    try {
      final topic = '$id/data';
      client.subscribe(topic, MqttQos.atLeastOnce);
      
      await for (final messages in client.updates!) {
        for (var message in messages) {
          final payload = (message.payload as MqttPublishMessage).payload.message;
          final data = json.decode(String.fromCharCodes(payload));
          
          final asset = AssetModel.fromJson(data);
          if (asset.id == id) {
            yield asset;
          }
        }
      }
    } catch (e) {
      throw const ServerException(
        message: 'Failed to watch asset updates',
        statusCode: 'WATCH_UPDATES_FAILED'        
      );
    }
  }

  @override
  Future<List<AssetModel>> getAssets() async {
    try {
      return _latestAssets.values.toList();
    } catch (e) {
      throw const ServerException(
        message: 'Failed to get assets list',
        statusCode: 'GET_ASSETS_FAILED'
      );
    }
  }

  @override
  Future<void> updateAsset(AssetModel asset) async {
    try {
      final payload = json.encode(asset.toJson());
      final builder = MqttClientPayloadBuilder();
      builder.addString(payload);
      
      client.publishMessage(
        '${asset.id}/data',
        MqttQos.atLeastOnce,
        builder.payload!,
      );
    } catch (e) {
      throw const ServerException(
        message: 'Failed to update asset',
        statusCode: 'UPDATE_ASSET_FAILED'        
      );
    }
  }
}