class Board
  attr_reader :board

  def initialize(default = true)
    @board = Array.new(8) { Array.new(8) }
    set_pieces if default
  end

  def set_pieces
    8.times do |row_idx|
      8.times do |col_idx|
        next if (row_idx + col_idx).odd?
        if [0, 1, 2].include?(row_idx)
          self[[row_idx, col_idx]] = Piece.new(self, [row_idx, col_idx], :red)
        elsif [5, 6, 7].include?(row_idx)
          self[[row_idx, col_idx]] = Piece.new(self, [row_idx, col_idx], :blue)
        end
      end
    end
  end

  def display
    puts '   a b c d e f g h'
    board.each_with_index do |row, row_idx|
      row_out = (8-row_idx).to_s + ' '
      row.each_with_index do |piece, col_idx|
        color = (col_idx + row_idx).even? ? :white : :light_black
        if !piece.nil?
          row_out += (piece.symbol + ' ').colorize(:background => color, :color => piece.color)
        else
          row_out += '  '.colorize(:background => color)
        end
      end
      puts row_out
    end
  end

  def move(input)
    from = input.first
    piece = self[from]
    piece.perform_moves(input)
  end

  def won?
    false
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

  def dup
    new_board = Board.new(false)
    pieces = board.flatten.compact
    pieces.each do |piece|
      new_board[piece.pos.dup] = piece.dup(new_board)
    end
    new_board
  end
end
