# frozen_string_literal: true
require 'rspec'

RSpec.describe "Day2" do
  let(:sample_input) do
    <<~INPUT
      forward 5
      down 5
      forward 8
      up 3
      down 8
      forward 2
    INPUT
  end

  describe "solve_part1" do
    it "returns 150" do
      expect(solve_part1(sample_input)).to eq(150)
    end
  end
end


def solve_part1(input = nil)
  with(input) do |io|
    commands =
      io.readlines
        .map(&:split)
        .each_with_object(Hash.new(0)) { |(command, amount), h| h[command] += amount.to_i }
    x = commands["forward"]
    depth = commands["down"] - commands["up"]
    x * depth
  end
end

def solve_part2(input = nil)
end

def with(input)
  if input.nil?
    open(File.join(__dir__, "input.txt")) { |io| yield io }
  elsif input.is_a?(String)
    yield StringIO.new(input)
  else
    yield input
  end
end

if $0 == __FILE__
  rspec_result = RSpec::Core::Runner.run([])
  if rspec_result == 0
    puts "part 1 solution: #{solve_part1}"
    puts "part 2 solution: #{solve_part2}"
  end
end
