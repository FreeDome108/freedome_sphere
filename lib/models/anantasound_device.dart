import 'dart:math';

/// Модель для anAntaSound Quantum Resonance Device
class AnantaSoundDevice {
  final String id;
  final String name;
  final DeviceStatus status;
  final QuantumResonanceField resonanceField;
  final ConsciousnessField consciousnessField;
  final MechanicalResonatorSettings resonatorSettings;
  final MIDIConfig midiConfig;
  final OSCConfig oscConfig;

  AnantaSoundDevice({
    required this.id,
    required this.name,
    required this.status,
    required this.resonanceField,
    required this.consciousnessField,
    required this.resonatorSettings,
    required this.midiConfig,
    required this.oscConfig,
  });

  AnantaSoundDevice copyWith({
    String? id,
    String? name,
    DeviceStatus? status,
    QuantumResonanceField? resonanceField,
    ConsciousnessField? consciousnessField,
    MechanicalResonatorSettings? resonatorSettings,
    MIDIConfig? midiConfig,
    OSCConfig? oscConfig,
  }) {
    return AnantaSoundDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      resonanceField: resonanceField ?? this.resonanceField,
      consciousnessField: consciousnessField ?? this.consciousnessField,
      resonatorSettings: resonatorSettings ?? this.resonatorSettings,
      midiConfig: midiConfig ?? this.midiConfig,
      oscConfig: oscConfig ?? this.oscConfig,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status.toJson(),
      'resonanceField': resonanceField.toJson(),
      'consciousnessField': consciousnessField.toJson(),
      'resonatorSettings': resonatorSettings.toJson(),
      'midiConfig': midiConfig.toJson(),
      'oscConfig': oscConfig.toJson(),
    };
  }

  factory AnantaSoundDevice.fromJson(Map<String, dynamic> json) {
    return AnantaSoundDevice(
      id: json['id'],
      name: json['name'],
      status: DeviceStatus.fromJson(json['status']),
      resonanceField: QuantumResonanceField.fromJson(json['resonanceField']),
      consciousnessField: ConsciousnessField.fromJson(json['consciousnessField']),
      resonatorSettings: MechanicalResonatorSettings.fromJson(json['resonatorSettings']),
      midiConfig: MIDIConfig.fromJson(json['midiConfig']),
      oscConfig: OSCConfig.fromJson(json['oscConfig']),
    );
  }
}

/// Статус устройства
class DeviceStatus {
  final bool isActive;
  final bool consciousnessConnected;
  final int connectedParticipants;
  final double currentFrequency;
  final double currentIntensity;
  final bool midiConnected;
  final bool oscConnected;

  DeviceStatus({
    required this.isActive,
    required this.consciousnessConnected,
    required this.connectedParticipants,
    required this.currentFrequency,
    required this.currentIntensity,
    required this.midiConnected,
    required this.oscConnected,
  });

  Map<String, dynamic> toJson() {
    return {
      'isActive': isActive,
      'consciousnessConnected': consciousnessConnected,
      'connectedParticipants': connectedParticipants,
      'currentFrequency': currentFrequency,
      'currentIntensity': currentIntensity,
      'midiConnected': midiConnected,
      'oscConnected': oscConnected,
    };
  }

  factory DeviceStatus.fromJson(Map<String, dynamic> json) {
    return DeviceStatus(
      isActive: json['isActive'],
      consciousnessConnected: json['consciousnessConnected'],
      connectedParticipants: json['connectedParticipants'],
      currentFrequency: json['currentFrequency'].toDouble(),
      currentIntensity: json['currentIntensity'].toDouble(),
      midiConnected: json['midiConnected'],
      oscConnected: json['oscConnected'],
    );
  }
}

/// 3D координаты в сферическом пространстве
class SphericalCoord {
  final double r;       // радиус
  final double theta;   // полярный угол (0-π)
  final double phi;     // азимутальный угол (0-2π)
  final double height;  // высота в куполе

  SphericalCoord({
    required this.r,
    required this.theta,
    required this.phi,
    required this.height,
  });

  Map<String, dynamic> toJson() {
    return {
      'r': r,
      'theta': theta,
      'phi': phi,
      'height': height,
    };
  }

  factory SphericalCoord.fromJson(Map<String, dynamic> json) {
    return SphericalCoord(
      r: json['r'].toDouble(),
      theta: json['theta'].toDouble(),
      phi: json['phi'].toDouble(),
      height: json['height'].toDouble(),
    );
  }
}

/// Квантовое резонансное поле
class QuantumResonanceField {
  final double frequency;           // Резонансная частота
  final double intensity;           // Интенсивность поля
  final double radius;              // Радиус поля
  final SphericalCoord center;      // Центр поля
  final double quantumPhase;        // Квантовая фаза
  final double coherenceTime;       // Время когерентности

  QuantumResonanceField({
    required this.frequency,
    required this.intensity,
    required this.radius,
    required this.center,
    required this.quantumPhase,
    required this.coherenceTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'frequency': frequency,
      'intensity': intensity,
      'radius': radius,
      'center': center.toJson(),
      'quantumPhase': quantumPhase,
      'coherenceTime': coherenceTime,
    };
  }

  factory QuantumResonanceField.fromJson(Map<String, dynamic> json) {
    return QuantumResonanceField(
      frequency: json['frequency'].toDouble(),
      intensity: json['intensity'].toDouble(),
      radius: json['radius'].toDouble(),
      center: SphericalCoord.fromJson(json['center']),
      quantumPhase: json['quantumPhase'].toDouble(),
      coherenceTime: json['coherenceTime'].toDouble(),
    );
  }
}

/// Поле сознания участников
class ConsciousnessField {
  final double radius;              // Радиус поля
  final double intensity;           // Интенсивность
  final double frequency;           // Базовая частота
  final List<double> participantWeights; // Веса участников
  final List<SphericalCoord> participantPositions; // Позиции участников
  final double coherenceRatio;      // Коэффициент когерентности

  ConsciousnessField({
    required this.radius,
    required this.intensity,
    required this.frequency,
    required this.participantWeights,
    required this.participantPositions,
    required this.coherenceRatio,
  });

  Map<String, dynamic> toJson() {
    return {
      'radius': radius,
      'intensity': intensity,
      'frequency': frequency,
      'participantWeights': participantWeights,
      'participantPositions': participantPositions.map((p) => p.toJson()).toList(),
      'coherenceRatio': coherenceRatio,
    };
  }

  factory ConsciousnessField.fromJson(Map<String, dynamic> json) {
    return ConsciousnessField(
      radius: json['radius'].toDouble(),
      intensity: json['intensity'].toDouble(),
      frequency: json['frequency'].toDouble(),
      participantWeights: List<double>.from(json['participantWeights']),
      participantPositions: (json['participantPositions'] as List)
          .map((p) => SphericalCoord.fromJson(p))
          .toList(),
      coherenceRatio: json['coherenceRatio'].toDouble(),
    );
  }
}

/// Настройки механических резонаторов
class MechanicalResonatorSettings {
  final double resonantFrequency;   // Резонансная частота
  final double amplitude;           // Амплитуда колебаний
  final double dampingCoefficient;  // Коэффициент затухания
  final String material;            // Материал резонатора
  final double temperature;         // Температура

  MechanicalResonatorSettings({
    required this.resonantFrequency,
    required this.amplitude,
    required this.dampingCoefficient,
    required this.material,
    required this.temperature,
  });

  Map<String, dynamic> toJson() {
    return {
      'resonantFrequency': resonantFrequency,
      'amplitude': amplitude,
      'dampingCoefficient': dampingCoefficient,
      'material': material,
      'temperature': temperature,
    };
  }

  factory MechanicalResonatorSettings.fromJson(Map<String, dynamic> json) {
    return MechanicalResonatorSettings(
      resonantFrequency: json['resonantFrequency'].toDouble(),
      amplitude: json['amplitude'].toDouble(),
      dampingCoefficient: json['dampingCoefficient'].toDouble(),
      material: json['material'],
      temperature: json['temperature'].toDouble(),
    );
  }
}

/// MIDI конфигурация
class MIDIConfig {
  final int channel;                // MIDI канал
  final int deviceId;              // ID устройства
  final bool sysexEnabled;         // Поддержка SysEx
  final int clockRate;             // Скорость MIDI

  MIDIConfig({
    this.channel = 1,
    this.deviceId = 0x7F,
    this.sysexEnabled = true,
    this.clockRate = 31250,
  });

  Map<String, dynamic> toJson() {
    return {
      'channel': channel,
      'deviceId': deviceId,
      'sysexEnabled': sysexEnabled,
      'clockRate': clockRate,
    };
  }

  factory MIDIConfig.fromJson(Map<String, dynamic> json) {
    return MIDIConfig(
      channel: json['channel'],
      deviceId: json['deviceId'],
      sysexEnabled: json['sysexEnabled'],
      clockRate: json['clockRate'],
    );
  }
}

/// OSC конфигурация
class OSCConfig {
  final String host;               // IP адрес
  final int port;                  // Порт TCP
  final bool tcpEnabled;           // Использование TCP
  final bool udpDisabled;          // Отключение UDP
  final int bufferSize;            // Размер буфера

  OSCConfig({
    this.host = "127.0.0.1",
    this.port = 8000,
    this.tcpEnabled = true,
    this.udpDisabled = true,
    this.bufferSize = 8192,
  });

  Map<String, dynamic> toJson() {
    return {
      'host': host,
      'port': port,
      'tcpEnabled': tcpEnabled,
      'udpDisabled': udpDisabled,
      'bufferSize': bufferSize,
    };
  }

  factory OSCConfig.fromJson(Map<String, dynamic> json) {
    return OSCConfig(
      host: json['host'],
      port: json['port'],
      tcpEnabled: json['tcpEnabled'],
      udpDisabled: json['udpDisabled'],
      bufferSize: json['bufferSize'],
    );
  }
}

/// MIDI сообщение
class MIDIMessage {
  final MIDIMessageType type;
  final int channel;
  final int note;
  final int velocity;
  final int controller;
  final int value;
  final List<int> sysexData;

  MIDIMessage({
    required this.type,
    required this.channel,
    required this.note,
    required this.velocity,
    required this.controller,
    required this.value,
    required this.sysexData,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'channel': channel,
      'note': note,
      'velocity': velocity,
      'controller': controller,
      'value': value,
      'sysexData': sysexData,
    };
  }

  factory MIDIMessage.fromJson(Map<String, dynamic> json) {
    return MIDIMessage(
      type: MIDIMessageType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      channel: json['channel'],
      note: json['note'],
      velocity: json['velocity'],
      controller: json['controller'],
      value: json['value'],
      sysexData: List<int>.from(json['sysexData']),
    );
  }
}

/// OSC сообщение
class OSCMessage {
  final String address;
  final List<double> floatValues;
  final List<int> intValues;
  final List<String> stringValues;

  OSCMessage({
    required this.address,
    required this.floatValues,
    required this.intValues,
    required this.stringValues,
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'floatValues': floatValues,
      'intValues': intValues,
      'stringValues': stringValues,
    };
  }

  factory OSCMessage.fromJson(Map<String, dynamic> json) {
    return OSCMessage(
      address: json['address'],
      floatValues: List<double>.from(json['floatValues']),
      intValues: List<int>.from(json['intValues']),
      stringValues: List<String>.from(json['stringValues']),
    );
  }
}

/// Типы MIDI сообщений
enum MIDIMessageType {
  noteOn,
  noteOff,
  controlChange,
  programChange,
  systemExclusive,
}
