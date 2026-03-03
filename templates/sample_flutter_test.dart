import 'package:flutter_test/flutter_test.dart';

/// Sample Flutter Widget Test
/// File pattern: *_test.dart
/// Run with: /flutter-test sample_flutter_test.dart

// --- Example model to test ---
class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
  };

  bool get isValidEmail => RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
}

// --- Example utility to test ---
String formatCurrency(double amount, {String symbol = '\$'}) {
  return '$symbol${amount.toStringAsFixed(2)}';
}

List<int> fibonacci(int n) {
  if (n <= 0) return [];
  if (n == 1) return [0];
  final list = [0, 1];
  for (var i = 2; i < n; i++) {
    list.add(list[i - 1] + list[i - 2]);
  }
  return list;
}

// --- Tests ---

void main() {
  group('User model', () {
    test('creates from JSON', () {
      final json = {'id': 1, 'name': 'Alice', 'email': 'alice@test.com'};
      final user = User.fromJson(json);

      expect(user.id, equals(1));
      expect(user.name, equals('Alice'));
      expect(user.email, equals('alice@test.com'));
    });

    test('serializes to JSON', () {
      final user = User(id: 1, name: 'Alice', email: 'alice@test.com');
      final json = user.toJson();

      expect(json['id'], equals(1));
      expect(json['name'], equals('Alice'));
    });

    test('validates email correctly', () {
      final validUser = User(id: 1, name: 'A', email: 'a@b.com');
      final invalidUser = User(id: 2, name: 'B', email: 'invalid');

      expect(validUser.isValidEmail, isTrue);
      expect(invalidUser.isValidEmail, isFalse);
    });
  });

  group('formatCurrency', () {
    test('formats with default symbol', () {
      expect(formatCurrency(1234.5), equals('\$1234.50'));
    });

    test('formats with custom symbol', () {
      expect(formatCurrency(99.9, symbol: '€'), equals('€99.90'));
    });

    test('handles zero', () {
      expect(formatCurrency(0), equals('\$0.00'));
    });
  });

  group('fibonacci', () {
    test('returns empty for n=0', () {
      expect(fibonacci(0), isEmpty);
    });

    test('returns [0] for n=1', () {
      expect(fibonacci(1), equals([0]));
    });

    test('returns correct sequence for n=7', () {
      expect(fibonacci(7), equals([0, 1, 1, 2, 3, 5, 8]));
    });
  });
}
