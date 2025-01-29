import 'package:asset_monitor/core/errors/failures.dart';
import 'package:asset_monitor/core/utils/typedef.dart';
import 'package:dartz/dartz.dart';

abstract class UsecaseWithParams<Type, Params> {
  const UsecaseWithParams();

  ResultFuture<Type> call(Params params);
}

abstract class UsecaseWithoutParams<Type> {
  const UsecaseWithoutParams();

  ResultFuture<Type> call();
}

abstract class StreamUsecaseWithParams<Type, Params> {
  const StreamUsecaseWithParams();

  Stream<Either<Failure, Type>> call(Params params);
}