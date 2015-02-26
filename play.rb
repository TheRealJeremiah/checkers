require_relative 'piece'
require_relative 'board'
require_relative 'game'
require_relative 'player'

if __FILE__ == $PROGRAM_NAME
  p1 = HumanPlayer.new
  p2 = HumanPlayer.new
  g = Game.new(p1, p2)
  g.play_game
end
