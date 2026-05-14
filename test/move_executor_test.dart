import 'dart:math';

import 'package:test/test.dart';
import 'package:chess_lib/src/chess-move.dart';
import 'package:chess_lib/src/chess-piece.dart';
import 'package:chess_lib/src/castling.dart';
import 'package:chess_lib/src/move-executor.dart';
import 'package:chess_lib/src/forsyth-edwards-notation.dart';

void main() {
  group('move-executor doMove', () {
    test('Standard move updates board correctly', () {
      final board = List.generate(8, (_) => List.filled(8, ChessPiece.none));
      board[1][1] = ChessPiece.white_pawn; // b2

      final move = ChessMove(
        piece: ChessPiece.white_pawn,
        start: const Point(1, 1),
        end: const Point(1, 2),
      );

      doMove(move, board);

      expect(board[1][1], ChessPiece.none);
      expect(board[2][1], ChessPiece.white_pawn);
    });

    test('Throws Exception if starting piece does not match', () {
      final board = List.generate(8, (_) => List.filled(8, ChessPiece.none));
      board[1][1] = ChessPiece.black_pawn; // Actually a black pawn

      final move = ChessMove(
        piece: ChessPiece.white_pawn, // Expecting white pawn
        start: const Point(1, 1),
        end: const Point(1, 2),
      );

      expect(() => doMove(move, board), throwsException);
    });

    test('Capture move replaces captured piece', () {
      final board = List.generate(8, (_) => List.filled(8, ChessPiece.none));
      board[1][1] = ChessPiece.white_pawn;
      board[2][2] = ChessPiece.black_pawn; // Target square

      final move = ChessMove(
        piece: ChessPiece.white_pawn,
        start: const Point(1, 1),
        end: const Point(2, 2),
        capture: ChessPiece.black_pawn,
      );

      doMove(move, board);

      expect(board[1][1], ChessPiece.none);
      expect(board[2][2], ChessPiece.white_pawn);
    });

    test('Promotion move places promoted piece on board', () {
      final board = List.generate(8, (_) => List.filled(8, ChessPiece.none));
      board[6][0] = ChessPiece.white_pawn; // a7

      final move = ChessMove(
        piece: ChessPiece.white_pawn,
        start: const Point(0, 6),
        end: const Point(0, 7),
        promotion: ChessPiece.white_queen,
      );

      doMove(move, board);

      expect(board[6][0], ChessPiece.none);
      expect(board[7][0], ChessPiece.white_queen);
    });

    test('Castling move invokes Castling.doMove', () {
      final customBoard = List.generate(8, (_) => List.filled(8, ChessPiece.none));
      customBoard[0][4] = ChessPiece.white_king; // e1
      customBoard[0][7] = ChessPiece.white_rook; // h1

      final move = ChessMove(
        piece: ChessPiece.white_king,
        start: const Point(4, 0),
        end: const Point(6, 0),
        castling: Castling.white_short,
      );

      doMove(move, customBoard);

      expect(customBoard[0][4], ChessPiece.none);
      expect(customBoard[0][7], ChessPiece.none);
      expect(customBoard[0][6], ChessPiece.white_king);
      expect(customBoard[0][5], ChessPiece.white_rook);
    });

    test('En passant move removes opponent pawn', () {
      final board = List.generate(8, (_) => List.filled(8, ChessPiece.none));
      board[4][0] = ChessPiece.white_pawn; // a5
      board[4][1] = ChessPiece.black_pawn; // b5 (just moved from b7)

      final move = ChessMove(
        piece: ChessPiece.white_pawn,
        start: const Point(0, 4),
        end: const Point(1, 5), // Capture b6
        capture: ChessPiece.black_pawn,
        enPessant: true,
      );

      doMove(move, board);

      expect(board[4][0], ChessPiece.none); // White pawn left
      expect(board[5][1], ChessPiece.white_pawn); // White pawn arrived
      expect(board[4][1], ChessPiece.none); // Black pawn captured via en passant
    });

    test('En passant throws if target pawn missing', () {
      final board = List.generate(8, (_) => List.filled(8, ChessPiece.none));
      board[4][0] = ChessPiece.white_pawn; // a5
      // board[4][1] is empty!

      final move = ChessMove(
        piece: ChessPiece.white_pawn,
        start: const Point(0, 4),
        end: const Point(1, 5), // Capture b6
        capture: ChessPiece.black_pawn,
        enPessant: true,
      );

      expect(() => doMove(move, board), throwsException);
    });
  });

  group('move-executor undoMove', () {
    test('Standard undo restores board state', () {
      final board = List.generate(8, (_) => List.filled(8, ChessPiece.none));
      board[2][1] = ChessPiece.white_pawn; // b3 (already moved)

      final move = ChessMove(
        piece: ChessPiece.white_pawn,
        start: const Point(1, 1),
        end: const Point(1, 2),
      );

      undoMove(move, board);

      expect(board[2][1], ChessPiece.none);
      expect(board[1][1], ChessPiece.white_pawn);
    });

    test('Capture undo restores captured piece', () {
      final board = List.generate(8, (_) => List.filled(8, ChessPiece.none));
      board[2][2] = ChessPiece.white_pawn; // Replaced black pawn

      final move = ChessMove(
        piece: ChessPiece.white_pawn,
        start: const Point(1, 1),
        end: const Point(2, 2),
        capture: ChessPiece.black_pawn,
      );

      undoMove(move, board);

      expect(board[1][1], ChessPiece.white_pawn);
      expect(board[2][2], ChessPiece.black_pawn);
    });

    test('Promotion undo restores original pawn', () {
      final board = List.generate(8, (_) => List.filled(8, ChessPiece.none));
      board[7][0] = ChessPiece.white_queen; // a8

      final move = ChessMove(
        piece: ChessPiece.white_pawn,
        start: const Point(0, 6),
        end: const Point(0, 7),
        promotion: ChessPiece.white_queen,
      );

      undoMove(move, board);

      expect(board[7][0], ChessPiece.none);
      expect(board[6][0], ChessPiece.white_pawn);
    });

    test('Castling undo invokes Castling.undoMove', () {
      final board = List.generate(8, (_) => List.filled(8, ChessPiece.none));
      board[0][6] = ChessPiece.white_king; // g1
      board[0][5] = ChessPiece.white_rook; // f1

      final move = ChessMove(
        piece: ChessPiece.white_king,
        start: const Point(4, 0),
        end: const Point(6, 0),
        castling: Castling.white_short,
      );

      undoMove(move, board);

      expect(board[0][4], ChessPiece.white_king);
      expect(board[0][7], ChessPiece.white_rook);
      expect(board[0][6], ChessPiece.none);
      expect(board[0][5], ChessPiece.none);
    });

    test('En passant undo restores both pawns', () {
      final board = List.generate(8, (_) => List.filled(8, ChessPiece.none));
      board[5][1] = ChessPiece.white_pawn; // b6
      // b5 is currently empty due to en passant capture

      final move = ChessMove(
        piece: ChessPiece.white_pawn,
        start: const Point(0, 4), // a5
        end: const Point(1, 5),   // b6
        capture: ChessPiece.black_pawn,
        enPessant: true,
      );

      undoMove(move, board);

      expect(board[5][1], ChessPiece.none); // White pawn removed from b6
      expect(board[4][0], ChessPiece.white_pawn); // White pawn restored to a5
      expect(board[4][1], ChessPiece.black_pawn); // Black pawn restored to b5
    });
  });
}
