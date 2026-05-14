import 'package:test/test.dart';
import 'package:chess_lib/src/chess-piece.dart';

void main() {
  group('pieceTypeFromChar', () {
    test('returns correct PieceType for valid unicode characters', () {
      for (final pt in PieceType.values) {
        expect(pieceTypeFromChar(pt.unicodeCharacter), equals(pt));
      }
    });

    test('throws Exception for invalid characters', () {
      expect(() => pieceTypeFromChar('p'), throwsException);
      expect(() => pieceTypeFromChar('n'), throwsException);
      expect(() => pieceTypeFromChar('k'), throwsException);
      expect(() => pieceTypeFromChar('A'), throwsException);
      expect(() => pieceTypeFromChar('1'), throwsException);
      expect(() => pieceTypeFromChar(''), throwsException);
      expect(() => pieceTypeFromChar(' '), throwsException);
    });
  });
}
