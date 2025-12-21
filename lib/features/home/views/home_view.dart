import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yaqeen_app/core/constants/app_constants.dart';
import 'package:yaqeen_app/features/home/cubit/home_cubit.dart';
import 'package:yaqeen_app/features/home/cubit/home_state.dart';
import 'package:screenshot/screenshot.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: const _HomeViewContent(),
    );
  }
}

class _HomeViewContent extends StatelessWidget {
  const _HomeViewContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(AppConstants.appName),
        actions: [
          BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              return IconButton(
                icon: state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.camera_alt),
                onPressed: state.isLoading
                    ? null
                    : () => context.read<HomeCubit>().takeScreenshot(),
                tooltip: 'Take Screenshot',
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {
          if (state.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state.isSuccess && !state.isLoading) {
            // Check if we just completed a screenshot operation
            // This is a simple check - you might want to add a success flag to state
          }
        },
        builder: (context, state) {
          return Screenshot(
            controller: context.read<HomeCubit>().screenshotController,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('You have pushed the button this many times:'),
                  const SizedBox(height: 16),
                  Text(
                    '${state.model.counter}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<HomeCubit>().incrementCounter(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

