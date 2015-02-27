require 'colorize'

class InvalidMoveError < ArgumentError
end

class Piece
  attr_reader :board, :color
  attr_accessor :king, :pos

  def initialize(board, pos, color)
    @board = board
    @pos = pos
    @color = color
    @king = false
  end

  def symbol
    king ? '♚' : '♟'
  end

  def set_king
    @king = true if color == :blue && pos[0] == 0
    @king = true if color == :red && pos[0] == 7
  end

  def perform_moves(moves)
    if moves.length == 2
      move(moves[1])
    else
      #check if any errors in our jumps
      new_board = board.dup
      new_piece = new_board[pos].dup(new_board)
      moves.drop(1).each do |new_pos|
        new_piece.perform_jump(new_pos)
      end
      #do the jumps
      moves.drop(1).each do |new_pos|
        self.perform_jump(new_pos)
      end

    end

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

  def dup(dup_board)
    Piece.new(dup_board, pos, color)
  end

  def perform_jump(new_pos)
    jump_dir = subtract(new_pos, pos)
    row, col = jump_dir
    dir = [row / 2, col / 2]
    raise InvalidMoveError.new('invalid jump') unless valid_take_dir?(dir)
    board[add(dir, pos)] = nil
    board[new_pos] = self
    board[pos] = nil
    @pos = new_pos
  end
  
  private

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
      take_dir = [2 * row, 2 * col]
      all_take_dirs << take_dir if valid_take_dir?(dir)
    end

    all_take_dirs
  end

  def perform_slide(new_pos)
    dir = subtract(new_pos, pos)
    return false unless valid_move_dir?(dir)
    board[new_pos] = self
    board[pos] = nil
    @pos = new_pos
  end


  def move_directions
    if king
      return [[1, 1], [1, -1], [-1, -1], [-1, 1]]
    else
      if color == :blue
        return [[-1, -1], [-1, 1]]
      else
        return [[1, -1], [1, 1]]
      end
    end
  end

  def valid_take_dir?(dir)
    new_pos = add(dir, pos)
    new_take_pos = add(dir, new_pos)
    on_board?(new_pos) && board.empty?(new_take_pos) && !board.empty?(new_pos)
  end

  def valid_move_dir?(dir)
    new_pos = add(dir, pos)
    on_board?(new_pos) && board.empty?(new_pos)
  end

  def on_board?(vec)
    row, col = vec
    row >= 0 && row <= 7 && col >= 0 && col <= 7
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
