# frozen_string_literal: true

module Rules
  OPTIONS = %w[1 2 3 4 5 6].freeze
  
  def self.options
    OPTIONS
  end

  def self.valid?(code)
    code.length == 4 && code.all? { |el| (1..6).include?(el.to_i) }
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
    @secret_code = code_maker.choose_code
    @guess = []
    @guess_count = 1
    start_game
  end

  def mode_selection
    puts 'Want to guess the code ? Type 1'
    puts 'Want to craft the code ? Type 2'
    puts 'Want to leave ? Type 9'

    answer = gets.chomp
    until %w[1 2 9].include?(answer)
      puts 'Code should be 4 digits long. Use digits between 1 to 6.'
      answer = gets.chomp
    end

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

  def start_game
    while guess != secret_code && guess_count <= 12

      puts "guess #{guess_count}/12"
      loop do
        @guess = code_guesser.guess_code
        break if Rules.valid?(guess)
      end

      absolute_check = []
      relative_check = []
      guess.each_with_index do |digit, index|
        next unless secret_code.include?(digit)

        if digit == secret_code[index]
          absolute_check.push('o')
        else
          relative_check.push('~')
        end
      end
      @guess_count += 1
      puts "#{guess.join('')}\t#{(absolute_check + relative_check).join('')}"
    end
  end
end

class Computer
  def initialize; end

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
  def initialize; end

  def choose_code
    puts 'Dear human, choose your secret code.'
    code = []
    code = gets.chomp.split('') until Rules.valid?(code)
    code
  end

  def guess_code
    puts "What's your guess, human person?"
    gets.chomp.split('')
  end
end

Game.new
