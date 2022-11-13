# frozen_string_literal: true

require_relative 'rules'

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
      possible_guesses.delete_if { |permutation| permutation.none? { |digit| gameboard.guess.include?(digit) } }

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
      possible_guesses.delete_if { |permutation| permutation.any? { |digit| gameboard.guess.include?(digit) } }
    end

    possible_guesses.sample
  end
end
