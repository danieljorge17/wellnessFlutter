import '../../core/services/uuid_service.dart';

class GetUuidUseCase {
  GetUuidUseCase(this.uuidService);

  final UuidService uuidService;

  String call() => uuidService.generateV4();
}
