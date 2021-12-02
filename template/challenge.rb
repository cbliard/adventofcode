# frozen_string_literal: true
require 'rspec'

RSpec.describe "Day3" do
  let(:sample_input) do
    <<~INPUT
    INPUT
  end

  describe "solve_part1" do
    subject { solve_part1(sample_input) }

    it { is_expected.to eq("xxx") }
  end

  describe "solve_part2" do
    subject { solve_part2(sample_input) }

    it { is_expected.to eq("xxx") }
  end
end


def solve_part1(input = nil)
  with(input) do |io|
    io.readlines
  end
end

def solve_part2(input = nil)
  with(input) do |io|
    io.readlines
  end
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
  RSpec.configure do |c|
    c.formatter = "documentation"
  end
  rspec_result = RSpec::Core::Runner.run([])
  if rspec_result == 0
    puts "part 1 solution: #{solve_part1}"
    puts "part 2 solution: #{solve_part2}"
  end
end
