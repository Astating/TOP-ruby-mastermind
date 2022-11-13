# frozen_string_literal: true

require_relative 'rules'

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
