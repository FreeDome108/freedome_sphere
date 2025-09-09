
// lib/models/zelim_format.dart

/// Represents a single element in the ZELIM quantum system.
class ZelimElement {
  final int id;
  final double orbitAngle;
  final double radius;
  final double phase;
  final double energyLevel;
  final int quantumState;
  final List<ZelimElement> subElements;
  final List<double> interactionMatrix;
  final double attractionCoefficient;
  final double conservationFactor;

  ZelimElement({
    required this.id,
    required this.orbitAngle,
    required this.radius,
    required this.phase,
    required this.energyLevel,
    required this.quantumState,
    required this.subElements,
    required this.interactionMatrix,
    required this.attractionCoefficient,
    required this.conservationFactor,
  });
}

/// Represents a group of ZELIM elements.
class ZelimElementGroup {
  final int id;
  final List<int> elementIds;
  final String groupType; // Using String for simplicity, could be an enum.
  final List<dynamic> interactionRules; // Placeholder for rules
  final double energyTransferRate;
  final double collisionThreshold;

  ZelimElementGroup({
    required this.id,
    required this.elementIds,
    required this.groupType,
    required this.interactionRules,
    required this.energyTransferRate,
    required this.collisionThreshold,
  });
}

/// Represents the overall ZELIM scene.
class ZelimScene {
  final int version;
  final DateTime timestamp;
  final int sceneSize;
  final String compression;
  final List<ZelimElement> elements;
  final List<ZelimElementGroup> groups;

  ZelimScene({
    required this.version,
    required this.timestamp,
    required this.sceneSize,
    required this.compression,
    required this.elements,
    required this.groups,
  });
}
