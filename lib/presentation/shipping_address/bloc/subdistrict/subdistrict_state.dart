part of 'subdistrict_bloc.dart';

@freezed
class SubdistrictState with _$SubdistrictState {
  const factory SubdistrictState.initial() = _Initial;
  const factory SubdistrictState.loading() = _Loading;
  const factory SubdistrictState.loaded(List<SubDistrict> subdistrict) =
      _Loaded;
  const factory SubdistrictState.error(String message) = _Error;
}
