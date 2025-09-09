
import 'package:freedome_sphere_flutter/models/freedome_learning_complex/lubomir_tutorial.dart';

final List<LubomirTutorial> tutorials = [
  LubomirTutorial(
    id: '1',
    name: 'Добро пожаловать в FREEDOME!',
    description: 'Ознакомительный тур по основным возможностям.',
    type: LubomirTutorialType.interactive,
    status: LubomirTutorialStatus.notStarted,
    createdAt: DateTime.now(),
    metadata: {},
    steps: [],
  ),
  LubomirTutorial(
    id: '2',
    name: 'Основы работы с 3D-сценой',
    description: 'Научитесь перемещаться и взаимодействовать с объектами.',
    type: LubomirTutorialType.spatial,
    status: LubomirTutorialStatus.notStarted,
    createdAt: DateTime.now(),
    metadata: {},
    steps: [],
  ),
  LubomirTutorial(
    id: '3',
    name: 'Работа с Квантовыми технологиями',
    description: 'Узнайте, как использовать Квантовые технологии в своих проектах.',
    type: LubomirTutorialType.visual,
    status: LubomirTutorialStatus.notStarted,
    createdAt: DateTime.now(),
    metadata: {},
    steps: [],
  ),
];
