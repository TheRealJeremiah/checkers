require 'colorize'

class InvalidMoveError < ArgumentError
end

class Piece
  attr_reader :board, :pos, :color, :king
  attr_writer :king
  def initialize(board, pos, color)
    @board = board
    @pos = pos
    @color = color
    @king = false
  end

  def symbol
    king ? '♚' : '♟'
  end

  def set_pos(pos)
    @pos = pos
  end

  def set_king
    @king = true if color == :blue && pos[0] == 0
    @king = true if color == :red && pos[0] == 7
  end

  def possible_slide
    all_move_dirs = []
    move_directions.each do |dir|
      all_move_dirs << dir if valid_move_dir?(dir)
    end

    all_move_dirs
  end

  def possible_jump
    all_take_dirs = []
    move_directions.each do |dir|
      row, col = dir
      take_dir = [2*row, 2*col]
      all_take_dirs << take_dir if valid_take_dir?(dir)
    end

    all_take_dirs
  end

  def move(new_pos)
    dir = subtract(new_pos, pos)
    if possible_slide.include?(dir)
      perform_slide(new_pos)
      set_king
    elsif possible_jump.include?(dir)
      perform_jump(new_pos)
      set_king
    else
      raise InvalidMoveError.new("You can't move there!")
    end
  end

  def perform_slide(new_pos)
    board[pos] = nil
    board[new_pos] = self
    set_pos(new_pos)
  end

  def perform_jump(new_pos)
    jump_dir = subtract(new_pos, pos)
    row, col = jump_dir
    dir = [row / 2, col / 2]

    board[pos] = nil
    board[add(dir,pos)] = nil
    board[new_pos] = self
    set_pos(new_pos)
  end

  def move_directions
    if king
      return [[1, 1], [1, -1], [-1, -1], [-1, 1]]
    else
      if color == :blue
        return [[-1, -1],[-1, 1]]
      else
        return [[1, -1], [1, 1]]
      end
    end
  end

  def valid_take_dir?(dir)
    row, col = dir
    take = [2*row, 2*col]
    new_pos = add(dir, pos)
    new_take_pos = add(take, pos)
    on_board?(new_pos) && board.empty?(new_take_pos) && !board.empty?(new_pos)
  end

  def valid_move_dir?(dir)
    new_pos = add(dir, pos)
    on_board?(new_pos) && board.empty?(new_pos)
  end

  def on_board?(vec)
    row, col = vec
    row >=0 && row <= 7 && col >=0 && col <= 7
  end

  def add(vec1, vec2)
    x1, y1 = vec1
    x2, y2 = vec2
    [x1 + x2, y1 + y2]
  end

  def subtract(vec1, vec2)
    x1, y1 = vec1
    x2, y2 = vec2
    [x1 - x2, y1 - y2]
  end
end

class Board
  attr_reader :board

  def initialize
    @board = Array.new(8){Array.new(8)}
    set_pieces
  end

  def set_pieces
    @board.each_with_index do |row, row_idx|
      row.each_with_index do |piece, col_idx|
        player = (row_idx + col_idx).even?
        if player
          if [0,1,2].include?(row_idx)
            self[[row_idx, col_idx]] = Piece.new(self, [row_idx, col_idx], :red)
          elsif [5,6,7].include?(row_idx)
            self[[row_idx, col_idx]] = Piece.new(self, [row_idx, col_idx], :blue)
          end
        end
      end
    end
  end

  def display
    puts "   a b c d e f g h"
    board.each_with_index do |row, row_idx|
      row_out = (8-row_idx).to_s + " "
      row.each_with_index do |piece, col_idx|
        color = (col_idx + row_idx).even? ? :white : :light_black
        if !piece.nil?
          row_out += (piece.symbol + " ").colorize(:background => color, :color => piece.color)
        else
          row_out += "  ".colorize(:background => color)
        end
      end
      puts row_out
    end
  end

  def move(input)
    from, to = input
    piece = self[from]
    piece.move(to)
  end

  def won?
    true
  end

  def empty?(pos)
    x, y = pos
    @board[x][y].nil?
  end

  def [](pos)
    x, y = pos
    @board[x][y]
  end

  def []=(pos, piece)
    x, y = pos
    @board[x][y] = piece
  end
end

class Game
  attr_reader :board, :player1, :player2
  def initialize(player1, player2)
    @board = Board.new
    @player1 = player1
    @player1.color = :blue
    @player2 = player2
    @player2.color = :red
  end

  def play_game
    turn = player1
    color = turn.color
    board.display
    while board.won?
      move = turn.get_move
      from, to = move
      if board[from].nil?
        puts "There is no piece there!"
        next
      end
      if board[from].color != color
        puts "Wrong color!"
        next
      end

      begin
        board.move(move)
      rescue InvalidMoveError => e
        puts e
        retry
      end
      board.display
      turn = switch_turn(turn)
      color = turn.color
    end
  end

  def switch_turn(turn)
    turn == player1 ? player2 : player1
  end
end

class HumanPlayer
  attr_accessor :color

  def get_move
    parse(gets.chomp)
  end

  def parse(input)
    letters = ('a'..'h').to_a
    col1 = letters.index(input[0])
    row1 = 8 - input[1].to_i
    col2 = letters.index(input[3])
    row2 = 8 - input[4].to_i

    [[row1,col1],[row2,col2]]
  end
end

if __FILE__ == $PROGRAM_NAME
  p1 = HumanPlayer.new
  p2 = HumanPlayer.new
  g = Game.new(p1, p2)
  g.play_game
end
