# frozen_string_literal: true

module Rules
  OPTIONS = %w[1 2 3 4 5 6].freeze

  def self.options
    OPTIONS
  end

  def self.valid?(code)
    code.length == 4 && code.all? { |el| OPTIONS.include?(el) }
  end
end

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
    puts "\n"
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

class Computer
  private

  attr_accessor :gameboard, :possible_guesses

  public

  def initialize(gameboard)
    @gameboard = gameboard
    @possible_guesses = Rules.options.repeated_permutation(4).to_a
  end

  def choose_code
    puts 'Computer is thinking...'
    puts 'Computer has chosen a code.'
    Array.new(4) { Rules.options.sample }
  end

  def guess_code
    puts 'Computer is computing its guess...'
    sleep 1
    
    possible_guesses.delete(gameboard.guess)
    if gameboard.pegs.any?(/[o~]/)
      possible_guesses.delete_if {|permutation| permutation.none? {|digit| gameboard.guess.include?(digit)}}

      gameboard_absolute_pegs_count = gameboard.pegs.count('o')
      possible_guesses.delete_if do |permutation|
        matching_positions_count = 0
        permutation.each_with_index do |digit, index|
          break if matching_positions_count > gameboard_absolute_pegs_count
          matching_positions_count += 1 if digit == gameboard.guess[index]
        end
        matching_positions_count != gameboard_absolute_pegs_count ? rand(10) < 5 : false
      end
    end

    if gameboard.pegs.none?(/[o~]/)
      possible_guesses.delete_if{|permutation| permutation.any? {|digit| gameboard.guess.include?(digit)}}
    end
    
    possible_guesses.sample
  end
end

class Human
  def choose_code
    puts 'Dear human, choose your secret code.'
    loop do
      code = gets.chomp.split('')
      return code if Rules.valid?(code)

      puts 'Code should be 4 digits long. Use digits between 1 to 6.'
    end
  end

  def guess_code
    puts "What's your guess, human person? (4 digits from 1 to 6)"
    gets.chomp.split('')
  end
end

Game.new
