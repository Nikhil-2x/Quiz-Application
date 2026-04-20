import 'package:flutter/material.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({
    super.key,
    required this.name,
    required this.analysisFuture,
  });

  final String name;
  final Future<String> analysisFuture;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('AI Analysis')),
      body: FutureBuilder<String>(
        future: analysisFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: colorScheme.error,
                          size: 36,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Unable to load AI analysis right now.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          final analysis = snapshot.data ?? 'No analysis available.';

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$name\'s Performance Report',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 14),
                    ..._buildFormattedAnalysis(analysis, colorScheme),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildFormattedAnalysis(String raw, ColorScheme colorScheme) {
    final lines = raw.split('\n').map((line) => line.trim()).toList();
    final widgets = <Widget>[];

    for (final line in lines) {
      if (line.isEmpty) {
        widgets.add(SizedBox(height: 8));
        continue;
      }

      if (line.startsWith('**') && line.endsWith('**') && line.length > 4) {
        final heading = line.substring(2, line.length - 2);
        widgets.add(
          Padding(
            padding: EdgeInsets.only(top: 6, bottom: 6),
            child: Text(
              heading,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
        );
        continue;
      }

      if (line.startsWith('- ')) {
        final bullet = line.substring(2).trim();
        widgets.add(
          Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 7),
                  child: Icon(
                    Icons.circle,
                    size: 7,
                    color: colorScheme.secondary,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(child: Text(bullet, style: TextStyle(fontSize: 15))),
              ],
            ),
          ),
        );
        continue;
      }

      widgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(line, style: TextStyle(fontSize: 15, height: 1.4)),
        ),
      );
    }

    return widgets;
  }
}
