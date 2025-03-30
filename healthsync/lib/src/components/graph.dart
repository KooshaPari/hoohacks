import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

List<String> days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];


class WeeklyGraph extends StatefulWidget {
  final String title;
  final List<double> values;
  final Color color;

  const WeeklyGraph({super.key, this.title = 'Untitled graph', required this.values, this.color = Colors.green});

  @override
  State<WeeklyGraph> createState() => _WeeklyGraphState();
}

class _WeeklyGraphState extends State<WeeklyGraph> {

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AspectRatio(
                aspectRatio: 2,
                child: BarChart(
                  BarChartData(
                    barGroups: _generateBarGroups(widget.values, widget.color),
                    titlesData: FlTitlesData(
                      // show widget.title as the title of the graph
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            final maxValue = widget.values.reduce((a, b) => a > b ? a : b);
                            if (value == 0) {
                              return const Text('0', style: TextStyle(fontSize: 12));
                            } else if (value == maxValue / 4) {
                              return Text((maxValue / 4).toInt().toString(), style: const TextStyle(fontSize: 12));
                            } else if (value == maxValue / 2) {
                              return Text((maxValue / 2).toInt().toString(), style: const TextStyle(fontSize: 12));
                            } else if (value == 3 * maxValue / 4) {
                              return Text((3 * maxValue / 4).toInt().toString(), style: const TextStyle(fontSize: 12));
                            } else if (value == maxValue) {
                              return Text(maxValue.toInt().toString(), style: const TextStyle(fontSize: 12));
                            }
                            return const SizedBox.shrink(); // Hide other labels
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              days[value.toInt()], // Show x-axis indices
                              style: const TextStyle(fontSize: 12),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false), // Hide top titles
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false), // Hide right titles
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false), // Hide grid lines
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<BarChartGroupData> _generateBarGroups(values, color) {
    return List.generate(values.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: values[index],
            color: color,
            width: 20,
          ),
        ],
      );
    });
  }