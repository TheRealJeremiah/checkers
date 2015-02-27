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
    coordinates = input.split
    coordinates.map { |let_num| row_col(let_num) }
  end

  def row_col(letter_number)
    letters = ('a'..'h').to_a
    row = 8 - Integer(letter_number[1])
    col = letters.index(letter_number[0])

    raise ArgumentError.new("column not a letter") if col.nil?
    [row,col]
  end

end
