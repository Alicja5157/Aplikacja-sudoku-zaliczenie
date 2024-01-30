import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(SudokuApp());

class SudokuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku',
      home: SudokuScreen(),
    );
  }
}

class SudokuScreen extends StatefulWidget {
  @override
  _SudokuScreenState createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  late List<List<int?>> _puzzle;
  late List<List<bool>> _userInput;

  @override
  void initState() {
    super.initState();
    _generatePuzzle();
  }

  void _generatePuzzle() {
    var rng = Random();
    _puzzle = List.generate(9, (_) => List.generate(9, (_) => null));
    _userInput = List.generate(9, (_) => List.generate(9, (_) => false));

    _fillSudoku(_puzzle, 0, 0, rng);

    for (int i = 0; i < 30; i++) {
      int row = rng.nextInt(9);
      int col = rng.nextInt(9);
      _puzzle[row][col] = null;
    }
  }

  bool _solveSudoku(List<List<int?>> puzzle) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (puzzle[row][col] == null) {
          for (int num = 1; num <= 9; num++) {
            if (_isSafe(puzzle, row, col, num)) {
              puzzle[row][col] = num;
              if (_solveSudoku(puzzle)) {
                return true;
              }
              puzzle[row][col] = null;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  bool _isSafe(List<List<int?>> puzzle, int row, int col, int num) {
    for (int x = 0; x < 9; x++) {
      if (puzzle[row][x] == num || puzzle[x][col] == num) {
        return false;
      }
    }

    int startRow = row - row % 3;
    int startCol = col - col % 3;
    for (int x = 0; x < 3; x++) {
      for (int y = 0; y < 3; y++) {
        if (puzzle[startRow + x][startCol + y] == num) {
          return false;
        }
      }
    }

    return true;
  }

  bool _fillSudoku(List<List<int?>> puzzle, int row, int col, Random rng) {
    if (row == 9) {
      row = 0;
      col++;
      if (col == 9) {
        return true;
      }
    }

    List<int> numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    numbers.shuffle(rng);

    for (int i = 0; i < 9; i++) {
      int number = numbers[i];
      if (_isSafe(puzzle, row, col, number)) {
        puzzle[row][col] = number;
        if (_fillSudoku(puzzle, row + 1, col, rng)) {
          return true;
        }
        puzzle[row][col] = null;
      }
    }

    return false;
  }

  void _enterNumber(int number, int row, int col) {
    if (_puzzle[row][col] == null || _userInput[row][col]) {
      setState(() {
        _puzzle[row][col] = number;
        _userInput[row][col] = true;
      });
    }
  }

  int _selectedRow = -1;
  int _selectedCol = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sudoku'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GridView.count(
              crossAxisCount: 9,
              children: List.generate(81, (index) {
                int row = index ~/ 9;
                int col = index % 9;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRow = row;
                      _selectedCol = col;
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: row % 3 == 0 ? Colors.black : Colors.grey,
                          width: row % 3 == 0 ? 3.0 : 1.0,
                        ),
                        left: BorderSide(
                          color: col % 3 == 0 ? Colors.black : Colors.grey,
                          width: col % 3 == 0 ? 3.0 : 1.0,
                        ),
                        right: BorderSide(
                          color: col % 3 == 2 ? Colors.black : Colors.transparent,
                          width: 1.0,
                        ),
                        bottom: BorderSide(
                          color: row % 3 == 2 ? Colors.black : Colors.transparent,
                          width: 1.0,
                        ),
                      ),
                      color: (_selectedRow == row && _selectedCol == col)
                          ? Colors.greenAccent
                          : (_userInput[row][col]
                          ? Colors.lightBlueAccent
                          : Colors.white),
                    ),
                    child: Text(
                      _puzzle[row][col] == null ? '' : _puzzle[row][col].toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              for (int i = 1; i <= 5; i++)
                _buildNumberButton(i),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              for (int i = 6; i <= 9; i++)
                _buildNumberButton(i),
            ],
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _generatePuzzle();
                _selectedRow = -1;
                _selectedCol = -1;
              });
            },
            child: Text('New Game'),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNumberButton(int number) {
    return ElevatedButton(
      onPressed: () {
        if (_selectedRow != -1 && _selectedCol != -1) {
          _enterNumber(number, _selectedRow, _selectedCol);
        }
      },
      child: Text(
        number.toString(),
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
