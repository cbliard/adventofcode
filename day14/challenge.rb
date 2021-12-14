# frozen_string_literal: true
require 'benchmark'
require 'rspec'
require 'set'
require 'timeout'

PART_1_EXAMPLE_SOLUTION = 1588
PART_2_EXAMPLE_SOLUTION = 2188189693529
TIMEOUT_SECONDS = 30

RSpec.describe "Day 14" do
  let(:sample_input) do
    <<~INPUT
      NNCB

      CH -> B
      HH -> N
      CB -> H
      NH -> C
      HB -> C
      HC -> B
      HN -> C
      NN -> C
      BH -> H
      NC -> B
      NB -> B
      BN -> B
      BB -> N
      BC -> B
      CC -> N
      CN -> C
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

class ExtendedPolymerization
  def initialize(input)
    @input = input
  end

  def rules
    @rules ||= @input
      .filter { _1.include?("->") }
      .map { _1.strip.split(" -> ") }
      .map { |(pair, el)| [pair, ["#{pair[0]}#{el}", "#{el}#{pair[1]}"]] }
      .to_h
  end

  def template
    @template ||= @input.first.strip.split("")
  end

  def part1
    generate(initial_pairs_counts, 10)
  end

  def part2
    generate(initial_pairs_counts, 40)
  end

  def initial_pairs_counts
    template.each_cons(2).map(&:join).tally
  end

  def result(pairs_counts)
    counts = element_counts(pairs_counts).values
    counts.max - counts.min
  end

  def element_counts(pairs_counts)
    counts = pairs_counts.reduce(Hash.new(0)) do |counts, (pair, count)|
      counts[pair[0]] += count
      counts
    end
    counts[template[-1]] += 1
    counts
  end

  def generate(pairs_counts, n)
    return result(pairs_counts) if n == 0

    generate(polymerize(pairs_counts), n - 1)
  end

  def polymerize(pairs_counts)
    pairs_counts.reduce(Hash.new(0)) do |counts, (pair, count)|
      p1, p2 = rules[pair]
      counts[p1] += count
      counts[p2] += count
      counts
    end
  end
end

def solve_part1(input = nil)
  with(input) do |io|
    ExtendedPolymerization.new(io.readlines).part1
  end
end

def solve_part2(input = nil)
  with(input) do |io|
    ExtendedPolymerization.new(io.readlines).part2
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
    c.filter_run_when_matching :focus
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
