# frozen_string_literal: true
require 'rspec'

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
    subject { solve_part1(sample_input) }

    it { is_expected.to eq("copy_solution_of_part_1_example_here") }
  end

  xdescribe "solve_part2" do
    subject { solve_part2(sample_input) }

    it { is_expected.to eq("copy_solution_of_part_2_example_here") }
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
    c.fail_fast = true
    c.formatter = "documentation"
  end
  rspec_result = RSpec::Core::Runner.run([])
  if rspec_result == 0
    puts "part 1 solution: #{solve_part1}"
    puts "part 2 solution: #{solve_part2}"
  end
end
