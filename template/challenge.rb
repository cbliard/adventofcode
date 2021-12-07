# frozen_string_literal: true
require 'benchmark'
require 'rspec'
require 'timeout'

PART_1_EXAMPLE_SOLUTION = nil
PART_2_EXAMPLE_SOLUTION = nil
TIMEOUT_SECONDS = 5

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

    it { is_expected.to eq(PART_1_EXAMPLE_SOLUTION.to_s) }
  end

  if PART_2_EXAMPLE_SOLUTION
    describe "solve_part2" do
      subject { solve_part2(sample_input).to_s }

      it { is_expected.to eq(PART_2_EXAMPLE_SOLUTION.to_s) }
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

def run_rspec
  RSpec.configure do |c|
    c.fail_fast = true
    c.formatter = "documentation"
    c.around(:each) do |example|
      Timeout::timeout(TIMEOUT_SECONDS) {
        example.run
      }
    end
  end
  rspec_result = RSpec::Core::Runner.run([])
  exit rspec_result if rspec_result != 0
end

def run_challenge
  [
    [1, PART_1_EXAMPLE_SOLUTION, :solve_part1],
    [2, PART_2_EXAMPLE_SOLUTION, :solve_part2],
  ].each do |part, part_implemented, solver|
    next unless part_implemented

    puts
    puts "==== PART #{part} ===="
    realtime = Benchmark.realtime do
      Timeout::timeout(TIMEOUT_SECONDS) do
        puts "answer: #{send(solver)}"
      end
    end
    puts "took: #{"%0.2f" % (realtime * 1000)}ms"
  end
end

if $0 == __FILE__
  run_rspec
  run_challenge
end
