part of 'asset_bloc.dart';

abstract class AssetState extends Equatable {
  const AssetState();

  @override
  List<Object?> get props => [];
}

class AssetInitial extends AssetState {
  const AssetInitial();
}

class AssetLoading extends AssetState {
  const AssetLoading();
}

class AssetError extends AssetState {
  final String message;
  final String? statusCode;
  
  const AssetError({
    required this.message, 
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];
}

class SingleAssetLoaded extends AssetState {
  final Asset asset;
  
  const SingleAssetLoaded({required this.asset});

  @override
  List<Object?> get props => [asset];
}

class MultipleAssetsLoaded extends AssetState {
  final List<Asset> assets;
  
  const MultipleAssetsLoaded({required this.assets});

  @override
  List<Object?> get props => [assets];
}