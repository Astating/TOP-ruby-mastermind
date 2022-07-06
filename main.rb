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

  attr_accessor :secret_code, :guess
  attr_writer :code_maker, :code_guesser, :guess_count

  public

  attr_reader :code_maker, :code_guesser, :guess_count

  def initialize
    @code_maker = nil
    @code_guesser = nil
    mode_selection
    puts "\n"
    @secret_code = code_maker.choose_code
    @guess = []
    @guess_count = 1
    play_game
  end

  def mode_selection
    puts 'Want to guess the code ? Type 1'
    puts 'Want to craft the code ? Type 2'
    puts 'Want to leave ? Type 9'

    answer = gets.chomp
    answer = gets.chomp until %w[1 2 9].include?(answer)

    case answer
    when '1'
      @code_maker = Computer.new
      @code_guesser = Human.new
    when '2'
      @code_maker = Human.new
      @code_guesser = Computer.new
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
    unguessed = guess[0..-1]

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

    puts "#{guess.join('')}\t#{(absolute_check + relative_check).join('')}"
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
  # def initialize; end

  def choose_code
    puts 'Computer is thinking...'
    puts 'Computer has chosen a code.'
    code = Array.new(4) { Rules.options.sample }
  end

  def guess_code
    puts 'Computer is computing its guess...'
    sleep 1
    guess = Array.new(4) { Rules.options.sample }
  end
end

class Human
  # def initialize; end

  def choose_code
    puts 'Dear human, choose your secret code.'
    loop do
        code = gets.chomp.split('')
        return code if Rules.valid?(code)
        puts 'Code should be 4 digits long. Use digits between 1 to 6.'
    end
  end

  def guess_code
    puts "What's your guess, human person?"
    gets.chomp.split('')
  end
end

Game.new
