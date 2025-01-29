part of 'asset_bloc.dart';

abstract class AssetEvent extends Equatable {
  const AssetEvent();

  @override
  List<Object?> get props => [];
}

class GetAssetEvent extends AssetEvent {
  final String id;
  
  const GetAssetEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class AssetFailureEvent extends AssetEvent {
  final String message;
  final String? statusCode;
  
  const AssetFailureEvent({
    required this.message, 
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];
}

class GetAssetsEvent extends AssetEvent {
  const GetAssetsEvent();
}

class StartWatchingAssetEvent extends AssetEvent {
  final String id;
  
  const StartWatchingAssetEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class StopWatchingAssetEvent extends AssetEvent {
  const StopWatchingAssetEvent();
}

class AssetUpdateReceived extends AssetEvent {
  final Asset asset;
  
  const AssetUpdateReceived({required this.asset});

  @override
  List<Object?> get props => [asset];
}