# frozen_string_literal: true

require_relative 'rules'
require_relative 'human'
require_relative 'computer'

class Game
  include Rules

  private

  attr_accessor :secret_code
  attr_writer :code_maker, :code_guesser, :guess_count, :pegs, :guess

  public

  attr_reader :code_maker, :code_guesser, :guess_count, :pegs, :guess

  def initialize
    @code_maker = nil
    @code_guesser = nil
    mode_selection
    puts "\n"
    @secret_code = code_maker.choose_code
    @guess = []
    @pegs = []
    @guess_count = 1
    play_game
  end

  private

  def mode_selection
    puts 'Want to guess the code ? Type 1'
    puts 'Want to craft the code ? Type 2'
    puts 'Want to leave ? Type 9'

    answer = gets.chomp until %w[1 2 9].include?(answer)

    case answer
    when '1'
      @code_maker = Computer.new(self)
      @code_guesser = Human.new
    when '2'
      @code_maker = Human.new
      @code_guesser = Computer.new(self)
    when '9'
      puts 'Bye! Bye!'
      exit
    else 'Hmm'
    end
  end

  def play_game
    puts <<~RULES

      Hints:
      o => Right digit, right position !
      ~ => Right digit, wrong position !

    RULES

    while guess != secret_code && guess_count <= 12
      play_turn
      display_pegs
      puts "\n"
    end
    conclusion
  end

  def play_turn
    puts "guess #{guess_count}/12"

    loop do
      @guess = code_guesser.guess_code
      break if Rules.valid?(guess)

      puts 'Code should be 4 digits long. Use digits between 1 to 6.'
    end

    @guess_count += 1
  end

  def display_pegs
    absolute_check = []
    relative_check = []
    code_to_check = secret_code.slice(0..-1)
    unguessed = guess[0..]

    unguessed.each_with_index do |digit, index|
      next unless code_to_check.include?(digit)

      next unless digit == code_to_check[index]

      absolute_check.push('o')
      code_to_check[index] = 'checked'
      unguessed[index] = 'assigned'
    end

    unguessed.each_with_index do |digit, index|
      next unless code_to_check.include?(digit)

      relative_check.push('~')
      i = code_to_check.index(digit)
      code_to_check[i] = 'checked'
      unguessed[index] = 'assigned'
    end
    @pegs = absolute_check + relative_check
    puts "#{guess.join('')}\t#{pegs.join('')}"
  end

  def conclusion
    if guess == secret_code
      puts "#{code_guesser.class} has deciphered the code! => #{secret_code.join('')}"
    else
      puts "#{code_maker.class}'s code was not deciphered in time... => #{secret_code.join('')}"
    end
  end
end
