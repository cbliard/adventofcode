# frozen_string_literal: true
require 'benchmark'
require 'rspec'
require 'set'
require 'timeout'

PART_1_EXAMPLE_SOLUTION = 1588
PART_2_EXAMPLE_SOLUTION = nil
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
      .map { _1.strip.split(" -> ").then { |(k, v)| [k.split(""), v] } }
      .to_h
  end

  def template
    @template ||= @input.first.strip.split("")
  end

  def part1
    polymer = generate(template, 10)
    part1_result(polymer)
  end

  def part1_result(polymer)
    most_common(polymer) - least_common(polymer)
  end

  def most_common(polymer)
    polymer.tally.values.max
  end

  def least_common(polymer)
    polymer.tally.values.min
  end

  def generate(template, count)
    return template if count == 0

    new_elements = rules.values_at(*template.each_cons(2))
    new_template = template.zip(new_elements).flatten.compact
    generate(new_template, count - 1)
  end
end

def solve_part1(input = nil)
  with(input) do |io|
    ExtendedPolymerization.new(io.readlines).part1
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
