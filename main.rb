class Game
    
    def initialize
        @code_maker = Computer.new
        @code_guesser = Human.new
        @secret_code = @code_maker.choose_code
        @guess = []
        @guess_count = 1
        start_game
    end

    def start_game
        while @guess != @secret_code && @guess_count <= 12
    
            puts "guess #{@guess_count}/12"
            @guess = gets.chomp.split('')
            @absolute_check = []
            @relative_check = []
            @guess.each_with_index do |digit, index|
                next unless @secret_code.include?(digit)
                digit == @secret_code[index] ?
                    @absolute_check.push("o") :
                    @relative_check.push("~")
            end
            @guess_count += 1
            puts [@absolute_check, @relative_check]
        end
    end
end

module Rules
    OPTIONS = %w[1 2 3 4 5 6]
    def self.options
        OPTIONS
    end
end

class Computer

    include Rules
    def initialize
    end

    def choose_code
        puts "Computer is thinking..."
        @code = Array.new(4) { Rules.options.sample }
    end
end

class Human

end

Game.new