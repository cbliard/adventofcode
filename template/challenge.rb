# frozen_string_literal: true
require 'rspec'

PART_1_EXAMPLE_SOLUTION = nil
PART_2_EXAMPLE_SOLUTION = nil

RSpec.describe "Day xxx" do
  let(:sample_input) do
    <<~INPUT
      copy_sample_input_here
    INPUT
  end

  it "has sample input ready" do
    expect(sample_input).not_to match(/copy_sample_input_here/)
  end

  describe "solve_part1" do
    subject { solve_part1(sample_input).to_s }

    it { is_expected.to eq(PART_1_EXAMPLE_SOLUTION) }
  end

  if PART_2_EXAMPLE_SOLUTION
    describe "solve_part2" do
      subject { solve_part2(sample_input).to_s }

      it { is_expected.to eq(PART_2_EXAMPLE_SOLUTION) }
    end
  end
end


def solve_part1(input = nil)
  with(input) do |io|
    io.readlines
    "part 1 not implemented"
  end
end

def solve_part2(input = nil)
  with(input) do |io|
    io.readlines
    "part 2 not implemented"
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
    c.fail_fast = true
    c.formatter = "documentation"
  end
  rspec_result = RSpec::Core::Runner.run([])
  if rspec_result == 0
    puts "part 1 solution: #{solve_part1}" if PART_1_EXAMPLE_SOLUTION
    puts "part 2 solution: #{solve_part2}" if PART_2_EXAMPLE_SOLUTION
  end
end
