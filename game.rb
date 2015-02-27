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
    until board.won?
      begin
        move = turn.request_move
        next unless pre_validate(move, color)
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

  def pre_validate(move, color)
    from, _to = move
    if board[from].nil?
      puts 'There is no piece there!'
      return false
    end
    if board[from].color != color
      puts 'Wrong color!'
      return false
    end
    true
  end

  def switch_turn(turn)
    turn == player1 ? player2 : player1
  end
end
