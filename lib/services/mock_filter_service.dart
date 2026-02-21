import '../models/filter_service.dart';

class MockFilterService {
  Future<List<FilterService>> getServices() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    return [
      FilterService(id: '1', name: 'AC Cleaning', description: 'Professional AC cleaning service', price: 150.0),
      FilterService(id: '2', name: 'Home Cleaning', description: 'Comprehensive home cleaning', price: 200.0),
      FilterService(id: '3', name: 'Carpet Cleaning', description: 'Deep carpet cleaning', price: 100.0),
      FilterService(id: '4', name: 'Toilet Cleaning', description: 'Sanitary toilet cleaning', price: 80.0),
    ];
  }
}
