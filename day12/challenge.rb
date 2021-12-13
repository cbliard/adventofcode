# frozen_string_literal: true
require 'benchmark'
require 'rspec'
require 'set'
require 'timeout'

PART_1_EXAMPLE_SOLUTION = 19
PART_2_EXAMPLE_SOLUTION = 103
TIMEOUT_SECONDS = 30

RSpec.describe "Day 12" do
  let(:sample_input) do
    <<~INPUT
      dc-end
      HN-start
      start-kj
      dc-start
      dc-HN
      LN-dc
      HN-end
      kj-sa
      kj-HN
      kj-dc
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

class PassagePathing
  def initialize(input)
    @input = input
  end

  def part1
    find_paths_to_end
    @paths.count
  end

  def part2
    @can_visit_one_small_cave_twice = true
    find_paths_to_end
    @paths.count
  end

  def paths
    @paths ||= []
  end

  def can_visit_cave?(cave, path)
    return true if big_cave?(cave)
    return true unless path.include?(cave)
    return false unless @can_visit_one_small_cave_twice

    path.filter { small_cave?(_1) }
      .tally
      .all? { |_, visit_count| visit_count == 1 }
  end

  def find_paths_to_end(path = ["start"])
    cave = path.last
    if cave == "end"
      paths << path
    else
      segments[cave]
        .filter { can_visit_cave?(_1, path) }
        .each do |next_cave|
          find_paths_to_end(path + [next_cave])
        end
    end
  end

  def big_cave?(cave)
    cave.upcase == cave
  end

  def small_cave?(cave)
    cave.upcase != cave
  end

  def segments
    return @segments if @segments

    @segments = Hash.new { |h,k| h[k] = Array.new }
    @input.each do |segment|
      from, to = segment.strip.split("-")
      segments[from] << to unless to == "start"
      segments[to] << from unless from == "start"
    end
    @segments
  end
end

def solve_part1(input = nil)
  with(input) do |io|
    PassagePathing.new(io.readlines).part1
  end
end

def solve_part2(input = nil)
  with(input) do |io|
    PassagePathing.new(io.readlines).part2
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

def timeout
  if File.open(__FILE__) { _1.grep(/[b]inding.irb\b/) }
    yield
  else
    Timeout::timeout(TIMEOUT_SECONDS) {
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
    [2, PART_2_EXAMPLE_SOLUTION, :solve_part2],
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
