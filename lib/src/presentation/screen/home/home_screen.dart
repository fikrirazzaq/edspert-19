import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning/src/values/strings.dart';

import '../../../data/datasource/remote/banner_remote_datasource.dart';
import '../../../data/datasource/remote/course_remote_datasource.dart';
import '../../../data/repository/banner_repository_impl.dart';
import '../../../data/repository/course_repository_impl.dart';
import '../../../domain/repository/course_repository.dart';
import '../../../domain/usecase/courses/get_courses_usecase.dart';
import '../../../domain/usecase/courses/get_exercises_by_course_usecase.dart';
import '../../../domain/usecase/get_banners_usecase.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/banner/banner_cubit.dart';
import '../../blocs/course/course_bloc.dart';
import '../../blocs/home_nav/home_nav_cubit.dart';
import '../../router/routes.dart';
import '../widgets/section_title.dart';
import 'widgets/banner_builder.dart';
import 'widgets/course_builder.dart';
import 'widgets/welcoming_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void didChangeDependencies() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      context.read<CourseBloc>().add(GetCoursesEvent(majorName: 'IPA'));
      await context.read<BannerCubit>().getBanners();
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F8),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.read<AuthBloc>().getCurrentSignedInEmail(),
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
            Text(
              'Selamat datang',
              style: TextStyle(fontSize: 10),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: CircleAvatar(
              backgroundColor: Colors.red,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WelcomingWidget(),
              const SizedBox(height: 16),
              const SectionTitle(title: 'Terbaru'),
              const SizedBox(height: 8),
              BlocBuilder<BannerCubit, BannerState>(
                builder: (context, bannerState) {
                  if (bannerState is BannerLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (bannerState is BannerSuccess) {
                    return BannerBuilder(bannerList: bannerState.banner);
                  }

                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionTitle(title: Strings.pilihPelajaran),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.courseListScreen);
                    },
                    child: const Text('Lihat Semua'),
                  )
                ],
              ),
              const SizedBox(height: 8),
              BlocBuilder<CourseBloc, CourseState>(
                builder: (context, courseState) {
                  if (courseState is LoadingGetCoursesState) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (courseState is SuccessGetCoursesState) {
                    return CourseBuilder(courseList: courseState.data ?? []);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
