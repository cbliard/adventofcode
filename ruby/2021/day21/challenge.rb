# frozen_string_literal: true

require "benchmark"
require "rspec"
require "set"
require "timeout"

PART_1_EXAMPLE_SOLUTION = 739785
PART_2_EXAMPLE_SOLUTION = 444356092776315
TIMEOUT_SECONDS = 30

RSpec.describe "Day 21" do
  let(:sample_input) do
    <<~INPUT
      Player 1 starting position: 4
      Player 2 starting position: 8
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

class DeterministicDice100
  attr_reader :rolls_count

  def initialize
    @rolls_count = 0
  end

  def roll
    @rolls_count % 100 + 1
  ensure
    @rolls_count += 1
  end

  def to_s
    "#<#{self.class.name} @rolls_count=#{rolls_count}"
  end
end

class DiracDice
  OUTCOMES = [1, 2, 3]
  ROLLS = OUTCOMES.product(OUTCOMES, OUTCOMES).map(&:sum)

  def roll
    ROLLS
  end
end

POSITIONS = [nil] + (1..10).to_a * 300

class Player < Struct.new(:position, :score, :goal)
  def move(count)
    self.position = POSITIONS[position + count]
    self.score += position
  end

  def won?
    score >= goal
  end
end

def solve_part1(input = nil)
  with(input) do |io|
    players = io.readlines.map { Player.new(_1.split.last.to_i, 0, 1000) }
    dice = DeterministicDice100.new
    players.cycle.each do |player|
      points = 3.times.map { dice.roll }.sum
      player.move(points)
      break if player.won?
    end
    loser = players.reject(&:won?).first
    loser.score * dice.rolls_count
  end
end

DIRAC_ROLLS = [
  [3, 1],
  [4, 3],
  [5, 6],
  [6, 7],
  [7, 6],
  [8, 3],
  [9, 1]
]

def universes(score, pos, score_other, pos_other, cache)
  return [0, 1] if score_other >= 21

  cache[[score, pos, score_other, pos_other]] ||= begin
    total1, total2 = [0, 0]
    DIRAC_ROLLS.each do |move, count|
      new_score = score
      new_pos1 = POSITIONS[pos + move]
      new_score += new_pos1
      sub2, sub1 = universes(score_other, pos_other, new_score, new_pos1, cache)

      total1 += sub1 * count
      total2 += sub2 * count
    end
    [total1, total2]
  end
end

def solve_part2(input = nil)
  with(input) do |io|
    p1_pos, p2_pos = io.readlines.map { _1.split.last.to_i }
    universes(0, p1_pos, 0, p2_pos, {}).max
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
