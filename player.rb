class HumanPlayer
  attr_accessor :color

  def request_move
    puts "Enter move:"
    begin
      parse(gets.chomp)
    rescue
      puts 'Wrong format, try again:'
      retry
    end
  end

  def parse(input)
    letters = ('a'..'h').to_a
    raise 'nope' if input.length!=5 || input[2] != ' '

    col1 = letters.index(input[0])
    raise "nope" if col1.nil?
    row1 = 8 - Integer(input[1])
    col2 = letters.index(input[3])
    raise "nope" if col2.nil?
    row2 = 8 - Integer(input[4])

    [[row1, col1], [row2, col2]]
  end
end
