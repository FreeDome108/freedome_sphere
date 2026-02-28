/// Device Selector Widget for FreeDome
/// 
/// Provides dropdown selection for audio/video devices

import 'package:flutter/material.dart';
import '../services/freedome_api_stubs.dart';

class FreedomeDeviceSelector extends StatefulWidget {
  final String deviceType;
  final List<DeviceInfo> devices;
  final DeviceInfo? selectedDevice;
  final ValueChanged<DeviceInfo?> onDeviceSelected;

  const FreedomeDeviceSelector({
    super.key,
    required this.deviceType,
    required this.devices,
    this.selectedDevice,
    required this.onDeviceSelected,
  });

  @override
  State<FreedomeDeviceSelector> createState() => _FreedomeDeviceSelectorState();
}

class _FreedomeDeviceSelectorState extends State<FreedomeDeviceSelector> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  widget.deviceType == 'audio' 
                    ? Icons.audiotrack 
                    : Icons.videocam,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.deviceType == 'audio' 
                    ? 'Аудио устройства' 
                    : 'Видео устройства',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.devices.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Устройства не найдены',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              DropdownButtonFormField<DeviceInfo>(
                value: widget.selectedDevice,
                decoration: const InputDecoration(
                  labelText: 'Выберите устройство',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: widget.devices.map((device) {
                  return DropdownMenuItem(
                    value: device,
                    child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              device.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!device.isAvailable)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Недоступно',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                        ],
                      ),
                  );
                }).toList(),
                onChanged: widget.onDeviceSelected,
              ),
            if (widget.selectedDevice != null) ...[
              const SizedBox(height: 16),
              _DeviceDetails(device: widget.selectedDevice!),
            ],
          ],
        ),
      ),
    );
  }
}

class _DeviceDetails extends StatelessWidget {
  final DeviceInfo device;

  const _DeviceDetails({required this.device});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ID: ${device.id}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                device.isAvailable ? Icons.check_circle : Icons.error,
                size: 16,
                color: device.isAvailable ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                device.isAvailable ? 'Доступно' : 'Недоступно',
                style: TextStyle(
                  color: device.isAvailable ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
