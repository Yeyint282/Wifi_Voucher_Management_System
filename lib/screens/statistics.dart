import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wifi_code.dart';
import '../provides/wifi_code_provider.dart';
import '../utils/date_utils.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WifiCodeProvider>(
      builder: (context, provider, child) {
        final totalCodes = provider.totalCodes;
        final uniqueNetworks = provider.uniqueNetworks;
        final durationBreakdown = provider.durationBreakdown;
        final recentCode = provider.mostRecentCode;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildStatCard(
                title: 'Total Vouchers',
                value: totalCodes.toString(),
                icon: Icons.confirmation_number,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                title: 'Unique WiFi Networks',
                value: uniqueNetworks.length.toString(),
                subtitle:
                uniqueNetworks.isEmpty ? 'None' : uniqueNetworks.join(', '),
                icon: Icons.wifi,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.orange),
                          const SizedBox(width: 8),
                          const Text(
                            'Duration Breakdown',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (durationBreakdown.isEmpty)
                        const Text('No data available')
                      else
                        ...durationBreakdown.entries.map((entry) {
                          final percentage = (entry.value / totalCodes * 100)
                              .toStringAsFixed(1);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  '${entry.key}: ${entry.value} ($percentage%)'),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: entry.value / totalCodes,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.orange),
                              ),
                              const SizedBox(height: 8),
                            ],
                          );
                        }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (recentCode != null) _buildRecentCodeCard(recentCode),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCodeCard(WifiCode code) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.new_releases, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'Most Recent Voucher',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Network: ${code.wifiName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Code: ${code.code}'),
            Text('Duration: ${code.duration}'),
            Text('Created: ${DateTimeUtils.formatDateTime(code.createdAt)}'),
            Text('Time ago: ${DateTimeUtils.timeAgo(code.createdAt)}'),
          ],
        ),
      ),
    );
  }
}
