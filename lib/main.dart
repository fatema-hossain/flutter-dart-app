import 'package:flutter/material.dart';
import 'core/theme/theme.dart';
import 'core/routing/router.dart';
import 'core/state/file_zen_scope.dart';
import 'data/controllers/file_zen_controller.dart';
import 'data/database/file_zen_database.dart';

void main() {
  runApp(const FileZenApp());
}

class FileZenApp extends StatefulWidget {
  const FileZenApp({super.key});

  @override
  State<FileZenApp> createState() => _FileZenAppState();
}

class _FileZenAppState extends State<FileZenApp> {
  late final FileZenController _controller;
  late final Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _controller = FileZenController(FileZenDatabase());
    _initialization = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        return FileZenScope(
          controller: _controller,
          child: MaterialApp.router(
            title: 'FileZen',
            theme: AppTheme.darkTheme,
            routerConfig: appRouter,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Color(0xFF0E0E0E),
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (_controller.error != null) {
                return Scaffold(
                  backgroundColor: const Color(0xFF0E0E0E),
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Unable to load FileZen data.\n${_controller.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              }

              return child ?? const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }
}
