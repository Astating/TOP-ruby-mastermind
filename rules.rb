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
