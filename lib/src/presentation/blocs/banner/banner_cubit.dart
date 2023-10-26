import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning/src/domain/usecase/get_banners_usecase.dart';

import '../../../domain/entity/banner_response_entity.dart';

part 'banner_state.dart';

class BannerCubit extends Cubit<BannerState> {
  final GetBannersUsecase getBannersUsecase;
  BannerCubit(this.getBannersUsecase) : super(BannerInitial());

  Future<void> getBanners() async {
    if (state is BannerSuccess) {
      return;
    }
    emit(BannerLoading());
    try {
      List<BannerDataEntity> banners = await getBannersUsecase();
      emit(BannerSuccess(banner: banners));
    } catch (e) {
      emit(BannerError(errorMessage: 'Something went wrong'));
    }
  }
}
