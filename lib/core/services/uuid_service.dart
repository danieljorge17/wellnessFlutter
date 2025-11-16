import 'package:uuid/uuid.dart';

class UuidService {
  const UuidService({required Uuid uuid}) : _uuid = uuid;

  final Uuid _uuid;

  String generateV4() => _uuid.v4();
}
