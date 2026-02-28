import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../technician_view_model.dart';

class BroadcastOverlay extends StatelessWidget {
  const BroadcastOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TechAppViewModel>(
      builder: (context, vm, child) {
        if (!vm.hasActiveBroadcast) return const SizedBox();

        return Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.4), // Dim the background
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40, offset: const Offset(0, 20)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTimer(vm.broadcastTimerSeconds),
                      const SizedBox(height: 32),
                      const Text(
                        'NEW EMERGENCY JOB',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Oil Change Required',
                        style: TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 24),
                      ),
                      const SizedBox(height: 24),
                      _buildJobDetails(),
                      const SizedBox(height: 32),
                      _buildActionButtons(vm),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimer(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    final timeStr = '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            value: seconds / 300,
            strokeWidth: 8,
            backgroundColor: Colors.grey.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
          ),
        ),
        Text(
          timeStr,
          style: const TextStyle(color: AppColors.secondaryLight, fontSize: 24, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  Widget _buildJobDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoPill(Icons.location_on_rounded, '3.2 KM'),
          Container(width: 1, height: 30, color: Colors.black.withOpacity(0.05)),
          _buildInfoPill(Icons.stars_rounded, 'SAR 150'),
        ],
      ),
    );
  }

  Widget _buildInfoPill(IconData icon, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryLight, size: 20),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 16)),
      ],
    );
  }

  Widget _buildActionButtons(TechAppViewModel vm) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: () => vm.stopBroadcast(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('ACCEPT JOB', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => vm.stopBroadcast(),
          child: Text(
            'DECLINE',
            style: TextStyle(color: Colors.black.withOpacity(0.4), fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
