# frozen_string_literal: true

require "benchmark"
require "rspec"
require "set"
require "timeout"

PART_1_EXAMPLE_SOLUTION = 12521
PART_2_EXAMPLE_SOLUTION = nil
TIMEOUT_SECONDS = 30

RSpec.describe "Day 23" do
  let(:sample_input) do
    <<~INPUT
    #############
    #...........#
    ###B#C#B#D###
      #A#D#C#A#
      #########
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

# Burrow Structure
#
# ######################################
# ## h1 h2    h3    h4    h5    h6 h7 ##
# ######## a1 ## b1 ## c1 ## d1 ########
#       ## a2 ## b2 ## c2 ## d2 ##
#       ##########################
#
BURROW_STRUCTURE = [
  [:h1, :h2, 1],
  [:h2, :h3, 2],
  [:h3, :h4, 2],
  [:h4, :h5, 2],
  [:h5, :h6, 2],
  [:h6, :h7, 1],
  [:a1, :h2, 2],
  [:a1, :h3, 2],
  [:b1, :h3, 2],
  [:b1, :h4, 2],
  [:c1, :h4, 2],
  [:c1, :h5, 2],
  [:d1, :h5, 2],
  [:d1, :h6, 2],
  [:a2, :a1, 1],
  [:b2, :b1, 1],
  [:c2, :c1, 1],
  [:d2, :d1, 1]
]

distances = Hash.new { |h, k| h[k] = {} }
BURROW_STRUCTURE.each do |pos1, pos2, distance|
  distances[pos1][pos2] = distance
  distances[pos2][pos1] = distance
end

routes = Hash.new { |h, k| h[k] = {} }
# routes.each

pp distances
pp routes
puts

class Burrow
  def initialize(positions)
    @positions = positions
  end

  def to_s
    <<~BURROW
      #############
      ##{symbol(:h1)}#{symbol(:h2)}.#{symbol(:h3)}.#{symbol(:h4)}.#{symbol(:h5)}.#{symbol(:h6)}#{symbol(:h7)}#
      ####{symbol(:a1)}##{symbol(:b1)}##{symbol(:c1)}##{symbol(:d1)}###
        ##{symbol(:a2)}##{symbol(:b2)}##{symbol(:c2)}##{symbol(:d2)}#
        #########
    BURROW
  end

  def symbol(position_name)
    @positions[position_name] || "."
  end
end

def solve_part1(input = nil)
  with(input) do |io|
    input = io.readlines
    puts input[2, 2]
      .flat_map { _1.scan(/[ABCD]/) }
      .then { |a1, b1, c1, d1, a2, b2, c2, d2|
        Burrow.new(a1: a1, b1: b1, c1: c1, d1: d1, a2: a2, b2: b2, c2: c2, d2: d2)
      }
  end
end

def solve_part2(input = nil)
  with(input) do |io|
    io.readlines
  end
end

def with(input)
  if input.nil?
    File.open(File.join(__dir__, "input.txt")) { |io| yield io }
  elsif input.is_a?(String)
    yield StringIO.new(input)
  else
    yield input
  end
end

def timeout
  if File.open(__FILE__) { _1.grep(/\sbinding.irb\b/) }
    yield
  else
    Timeout.timeout(TIMEOUT_SECONDS) {
      yield
    }
  end
end

def run_rspec
  RSpec.configure do |c|
    c.fail_fast = true
    c.formatter = "documentation"
    c.around(:each) do |example|
      timeout { example.run }
    end
  end
  rspec_result = RSpec::Core::Runner.run([])
  exit rspec_result if rspec_result != 0
end

def run_challenge
  [
    [1, PART_1_EXAMPLE_SOLUTION, :solve_part1],
    [2, PART_2_EXAMPLE_SOLUTION, :solve_part2]
  ].each do |part, part_implemented, solver|
    next unless part_implemented

    puts "==== PART #{part} ===="
    realtime = Benchmark.realtime do
      timeout do
        puts "answer: #{send(solver)}"
      end
    end
    puts "took: #{"%0.2f" % (realtime * 1000)}ms"
    puts
  end
end

if $0 == __FILE__
  run_rspec
  run_challenge
end
