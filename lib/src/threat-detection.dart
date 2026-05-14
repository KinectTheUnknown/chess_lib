import 'dart:math';

import 'chess-piece.dart';
import 'piece-movement.dart';
import 'player.dart';
import 'potential-moves.dart';

bool _directionalCheck(
    Point<int> s,
    Player attackingPlayer,
    List<Point<int>> directions,
    List<List<ChessPiece>> board,
    Set<PieceType> pieceTypes) {
  for (Point<int> d in directions) {
    Point<int> c = s + d;
    while (pointIsOnBoard(c)) {
      ChessPiece p = board[c.y][c.x];
      if (p == ChessPiece.none) {
        c += d;
      } else if (p != ChessPiece.none &&
          p.owner == attackingPlayer &&
          pieceTypes.contains(p.pieceType)) {
        return true;
      } else {
        break;
      }
    }
  }
  return false;
}

bool _squareChecks(Point<int> s, Player attackingPlayer, List<Point<int>> moves,
    List<List<ChessPiece>> board, Set<PieceType> pieceTypes) {
  for (Point<int> m in moves) {
    Point<int> c = s + m;
    if (pointIsOnBoard(c)) {
      ChessPiece p = board[c.y][c.x];
      if (p != ChessPiece.none &&
          p.owner == attackingPlayer &&
          pieceTypes.contains(p.pieceType)) {
        return true;
      }
    }
  }
  return false;
}

const _rookAndQueen = {PieceType.rook, PieceType.queen};
const _bishopAndQueen = {PieceType.bishop, PieceType.queen};
const _knightOnly = {PieceType.knight};
const _kingOnly = {PieceType.king};
const _pawnOnly = {PieceType.pawn};

const _whitePawnAttackDirections = [
  Point<int>(-1, -1),
  Point<int>(1, -1),
];

const _blackPawnAttackDirections = [
  Point<int>(-1, 1),
  Point<int>(1, 1),
];

bool isSquareAttacked(
    Point<int> square, Player attackingPlayer, List<List<ChessPiece>> board) {
  return _directionalCheck(
          square, attackingPlayer, rookDirections, board, _rookAndQueen) ||
      _directionalCheck(
          square, attackingPlayer, bishopDirections, board, _bishopAndQueen) ||
      _squareChecks(square, attackingPlayer, knightMoves, board, _knightOnly) ||
      _squareChecks(
          square, attackingPlayer, queenDirections, board, _kingOnly) ||
      _squareChecks(
          square,
          attackingPlayer,
          attackingPlayer == Player.white
              ? _whitePawnAttackDirections
              : _blackPawnAttackDirections,
          board,
          _pawnOnly);
}

bool isCheck(Player player, List<List<ChessPiece>> board) {
  for (int y = 0; y < 8; y++) {
    for (int x = 0; x < 8; x++) {
      ChessPiece p = board[y][x];
      if (p != ChessPiece.none &&
          p.owner == player &&
          p.pieceType == PieceType.king) {
        return isSquareAttacked(Point<int>(x, y), player.opposite, board);
      }
    }
  }
  return false;
}
