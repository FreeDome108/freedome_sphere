import 'package:flutter/material.dart';
import '../models/project.dart';

class Viewport3D extends StatelessWidget {
  final FreedomeProject? project;
  final bool isLoading;

  const Viewport3D({
    super.key,
    required this.project,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            Color(0xFF2A2A2A),
            Color(0xFF1A1A1A),
          ],
        ),
      ),
      child: Stack(
        children: [
          // 3D Viewport placeholder
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.view_in_ar,
                  size: 64,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  '3D Viewport',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white.withOpacity(0.5),
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Professional dome projection editor',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
                if (project != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A9EFF).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF4A9EFF).withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Project: ${project!.name}',
                      style: const TextStyle(
                        color: Color(0xFF4A9EFF),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Loading indicator
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A9EFF)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Viewport controls overlay
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildViewportButton(
                    icon: Icons.zoom_in,
                    onPressed: () {},
                    tooltip: 'Zoom In',
                  ),
                  const SizedBox(height: 4),
                  _buildViewportButton(
                    icon: Icons.zoom_out,
                    onPressed: () {},
                    tooltip: 'Zoom Out',
                  ),
                  const SizedBox(height: 4),
                  _buildViewportButton(
                    icon: Icons.rotate_left,
                    onPressed: () {},
                    tooltip: 'Rotate Left',
                  ),
                  const SizedBox(height: 4),
                  _buildViewportButton(
                    icon: Icons.rotate_right,
                    onPressed: () {},
                    tooltip: 'Rotate Right',
                  ),
                ],
              ),
            ),
          ),
          
          // Project info overlay
          if (project != null)
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Dome Settings',
                      style: const TextStyle(
                        color: Color(0xFF4A9EFF),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Radius: ${project!.dome.radius.toStringAsFixed(1)}m',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      'Type: ${project!.dome.projectionType}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      'Resolution: ${project!.dome.resolution.width}x${project!.dome.resolution.height}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildViewportButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ),
    );
  }
}
