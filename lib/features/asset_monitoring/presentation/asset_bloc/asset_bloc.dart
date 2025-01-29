import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:asset_monitor/core/errors/failures.dart';
import 'package:asset_monitor/features/asset_monitoring/domain/entities/asset.dart';
import 'package:asset_monitor/features/asset_monitoring/domain/usecases/get_asset.dart';
import 'package:asset_monitor/features/asset_monitoring/domain/usecases/get_assets.dart';
import 'package:asset_monitor/features/asset_monitoring/domain/usecases/watch_asset.dart';

part 'asset_event.dart';
part 'asset_state.dart';

class AssetBloc extends Bloc<AssetEvent, AssetState> {
  final GetAsset _getAsset;
  final GetAssets _getAssets;
  final WatchAsset _watchAsset;
  StreamSubscription<Either<Failure, Asset>>? _assetSubscription;

  AssetBloc({
    required GetAsset getAsset,
    required GetAssets getAssets,
    required WatchAsset watchAsset,
  }) : _getAsset = getAsset,
       _getAssets = getAssets,
       _watchAsset = watchAsset,
       super(const AssetInitial()) {
    on<GetAssetEvent>(_handleGetAsset);
    on<GetAssetsEvent>(_handleGetAssets);
    on<StartWatchingAssetEvent>(_handleStartWatching);
    on<StopWatchingAssetEvent>(_handleStopWatching);
    on<AssetUpdateReceived>(_handleAssetUpdate);
    on<AssetFailureEvent>(_handleAssetFailure);
  }

  Future<void> _handleGetAsset(
    GetAssetEvent event,
    Emitter<AssetState> emit,
  ) async {
    emit(const AssetLoading());

    final result = await _getAsset(event.id);

    result.fold(
      (failure) => emit(AssetError(
        message: failure.message,
        statusCode: failure.statusCode,
      )),
      (asset) => emit(SingleAssetLoaded(asset: asset)),
    );
  }

  Future<void> _handleGetAssets(
    GetAssetsEvent event,
    Emitter<AssetState> emit,
  ) async {
    emit(const AssetLoading());

    final result = await _getAssets();

    result.fold(
      (failure) => emit(AssetError(
        message: failure.message,
        statusCode: failure.statusCode,
      )),
      (assets) => emit(MultipleAssetsLoaded(assets: assets)),
    );
  }

  Future<void> _handleStartWatching(
    StartWatchingAssetEvent event,
    Emitter<AssetState> emit,
  ) async {
    await _assetSubscription?.cancel();
    
    _assetSubscription = _watchAsset(event.id).listen(
      (either) => either.fold(
        (failure) => add(AssetFailureEvent(
          message: failure.message,
          statusCode: failure.statusCode,
        )),
        (asset) => add(AssetUpdateReceived(asset: asset)),
      ),
    );
  }

  Future<void> _handleStopWatching(
    StopWatchingAssetEvent event,
    Emitter<AssetState> emit,
  ) async {
    await _assetSubscription?.cancel();
    _assetSubscription = null;
  }

  void _handleAssetUpdate(
    AssetUpdateReceived event,
    Emitter<AssetState> emit,
  ) {
    emit(SingleAssetLoaded(asset: event.asset));
  }

  void _handleAssetFailure(
    AssetFailureEvent event,
    Emitter<AssetState> emit,
  ) {
    emit(AssetError(
      message: event.message,
      statusCode: event.statusCode,
    ));
  }  

  @override
  Future<void> close() async {
    await _assetSubscription?.cancel();
    return super.close();
  }
}