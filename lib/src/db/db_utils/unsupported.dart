import 'db_utils.dart';

Never _unsupported() {
  throw UnsupportedError(
      'No suitable database implementation was found on this platform.');
}

DBUtils dbUtils() => _unsupported();
Future<void> initDbUtils() async => _unsupported();
