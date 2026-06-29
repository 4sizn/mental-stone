import 'package:flutter_test/flutter_test.dart';
import 'package:mental_stone_core/mental_stone_core.dart';

void main() {
  group('authErrorMessage', () {
    test('maps invalid credentials to Korean', () {
      final msg = authErrorMessage(
        const AuthException('Invalid login credentials'),
      );
      expect(msg, '이메일 또는 비밀번호가 올바르지 않습니다.');
    });

    test('maps already-registered to Korean', () {
      final msg = authErrorMessage(
        const AuthException('User already registered'),
      );
      expect(msg, '이미 가입된 이메일입니다.');
    });

    test('maps weak password to Korean', () {
      final msg = authErrorMessage(
        const AuthException('Password should be at least 6 characters'),
      );
      expect(msg, '비밀번호는 6자 이상이어야 합니다.');
    });

    test('falls back to a generic message for non-auth errors', () {
      final msg = authErrorMessage(Exception('boom'));
      expect(msg, '문제가 발생했습니다. 잠시 후 다시 시도해 주세요.');
    });

    test('maps a retryable fetch failure to a connectivity message', () {
      final msg = authErrorMessage(
        AuthRetryableFetchException(message: 'ClientException'),
      );
      expect(msg, '인터넷 연결을 확인해 주세요.');
    });

    test('maps a raw ClientException to a connectivity message', () {
      final msg = authErrorMessage(
        Exception('ClientException with SocketException: Failed host lookup'),
      );
      expect(msg, '인터넷 연결을 확인해 주세요.');
    });
  });

  group('Profile', () {
    test('name prefers displayName, then email local-part', () {
      expect(
        const Profile(id: '1', displayName: '희석', email: 'a@b.com').name,
        '희석',
      );
      expect(
        const Profile(id: '1', email: 'hsshin@rsupport.com').name,
        'hsshin',
      );
      expect(const Profile(id: '1').name, 'Friend');
    });

    test('fromMap parses a row', () {
      final p = Profile.fromMap({
        'id': 'uuid-1',
        'email': 'a@b.com',
        'display_name': 'A',
        'avatar_url': null,
        'created_at': '2026-06-21T00:00:00Z',
      });
      expect(p.id, 'uuid-1');
      expect(p.displayName, 'A');
      expect(p.createdAt?.year, 2026);
    });
  });

  group('entriesByDayOfMonth', () {
    JournalEntry entryOn(DateTime when) =>
        JournalEntry(id: when.toIso8601String(), userId: 'u', createdAt: when);

    test('buckets by day and excludes other months', () {
      final entries = [
        entryOn(DateTime(2026, 6, 28, 9)),
        entryOn(DateTime(2026, 6, 28, 18)),
        entryOn(DateTime(2026, 6, 29, 10)),
        entryOn(DateTime(2026, 5, 29, 10)), // other month
        entryOn(DateTime(2026, 7, 1, 10)), // other month
      ];
      final byDay = entriesByDayOfMonth(entries, 2026, 6);
      expect(byDay.keys.toSet(), {28, 29});
      expect(byDay[28]!.length, 2);
      expect(byDay[29]!.length, 1);
    });

    test('returns empty map when nothing matches', () {
      final byDay = entriesByDayOfMonth(
        [entryOn(DateTime(2026, 5, 1))],
        2026,
        6,
      );
      expect(byDay, isEmpty);
    });
  });
}
