abstract class HeartRateRepository {
  /// TODO: Implement BLE connection to read heart rate
  /// This will use the 'health' package or direct BLE in the future
  Future<void> connectToDevice();
  Stream<int> getHeartRateStream();
}
