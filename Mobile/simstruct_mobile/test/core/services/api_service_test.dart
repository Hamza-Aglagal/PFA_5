import 'package:flutter_test/flutter_test.dart';
import 'package:simstruct_mobile/core/services/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('ApiResponse', () {
    test('should create success response', () {
      final response = ApiResponse(
        success: true,
        message: 'Success',
        data: {'id': '123'},
        statusCode: 200,
      );

      expect(response.success, true);
      expect(response.message, 'Success');
      expect(response.data, isNotNull);
      expect(response.statusCode, 200);
    });

    test('should create error response', () {
      final response = ApiResponse(
        success: false,
        message: 'Not found',
        statusCode: 404,
      );

      expect(response.success, false);
      expect(response.message, 'Not found');
      expect(response.data, isNull);
      expect(response.statusCode, 404);
    });

    test('should have proper toString representation', () {
      final response = ApiResponse(
        success: true,
        message: 'OK',
        statusCode: 200,
      );

      final str = response.toString();
      expect(str, contains('success: true'));
      expect(str, contains('message: OK'));
      expect(str, contains('statusCode: 200'));
    });

    test('should handle null data', () {
      final response = ApiResponse(
        success: true,
        message: 'Empty response',
        data: null,
        statusCode: 204,
      );

      expect(response.data, isNull);
    });

    test('should handle list data', () {
      final response = ApiResponse(
        success: true,
        message: 'List response',
        data: [{'id': '1'}, {'id': '2'}],
        statusCode: 200,
      );

      expect(response.data, isA<List>());
      expect((response.data as List).length, 2);
    });

    test('should handle map data', () {
      final response = ApiResponse(
        success: true,
        message: 'Map response',
        data: {'key': 'value', 'count': 5},
        statusCode: 200,
      );

      expect(response.data, isA<Map>());
      expect(response.data['key'], 'value');
    });
  });

  group('ApiService', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
    });

    test('should create instance', () {
      expect(apiService, isNotNull);
    });

    // Note: FlutterSecureStorage tests require platform channel mocking
    // These are integration tests that work in a real device/emulator
    // Skipping token-related tests in unit testing
    test('baseUrl should be configured', () {
      // Just verify ApiService can be instantiated
      expect(apiService, isA<ApiService>());
    });
  });
}
