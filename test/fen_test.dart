import 'package:test/test.dart';
import 'package:chess_lib/chess_lib.dart';

void main() {
  test('FEN roundtrip', () {
    String startFen =
        "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
    var state = ChessGameState.fromFen(startFen);
    expect(state.forsythEdwardsNotation, startFen);
  });

  test('FEN half move clock increments and resets', () {
    String startFen =
        "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 10 1";
    var state = ChessGameState.fromFen(startFen);
    expect(state.halfMoveClock, 10);

    // Play a non-pawn, non-capture move (knight move)
    var knightMove =
        state.moves.firstWhere((m) => m.piece.pieceType == PieceType.knight);
    var nextState = state.playMove(knightMove);
    expect(nextState.halfMoveClock, 11);

    // Play a pawn move, should reset clock
    var pawnMove =
        nextState.moves.firstWhere((m) => m.piece.pieceType == PieceType.pawn);
    var pawnState = nextState.playMove(pawnMove);
    expect(pawnState.halfMoveClock, 0);

    // From pawnState, increment again
    var knightMove2 = pawnState.moves
        .firstWhere((m) => m.piece.pieceType == PieceType.knight);
    var knightState2 = pawnState.playMove(knightMove2);
    expect(knightState2.halfMoveClock, 1);
  });
}
