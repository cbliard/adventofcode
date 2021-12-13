# frozen_string_literal: true
require 'benchmark'
require 'rspec'
require 'timeout'

PART_1_EXAMPLE_SOLUTION = 1656
PART_2_EXAMPLE_SOLUTION = 195
TIMEOUT_SECONDS = 5

RSpec.describe "Day 11" do
  let(:sample_input) do
    <<~INPUT
      5483143223
      2745854711
      5264556173
      6141336146
      6357385478
      4167524645
      2176841721
      6882881134
      4846848554
      5283751526
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

class DumboOctopus
  attr_reader :levels

  def initialize(input)
    @levels ||= input
      .map { _1.strip.split("").map(&:to_i) }
    @generation = 0
  end

  def part1
    (0...100).reduce(0) do |count|
      generate
      count + flashes_count
    end
  end

  def part2
    generate until synchronized_flashes?
    @generation
  end

  def generate
    increase_all_energy_levels
    reset_energy_level_of_flashing_octopuses
    @generation += 1
  end

  def increase_all_energy_levels
    indices.each { |x, y| increase_energy_level(x, y) }
  end

  def increase_energy_level(x, y)
    levels[y][x] += 1
    increase_neighbors_energy_level(x, y) if levels[y][x] == 10
  end

  def increase_neighbors_energy_level(x, y)
    neighbors(x, y).each { |x, y| increase_energy_level(x, y) }
  end

  def indices
    @indices ||= (0..9).to_a.product((0..9).to_a)
  end

  def neighbors(x, y)
    [
      [x-1, y-1], [x, y-1], [x+1, y-1],
      [x-1, y], [x+1, y],
      [x-1, y+1], [x, y+1], [x+1, y+1],
    ].reject { |x, y| x < 0 || y < 0 || x > 9 || y > 9 }
  end

  def reset_energy_level_of_flashing_octopuses
    indices.each { |x, y| levels[y][x] = 0 if levels[y][x] > 9 }
  end

  def synchronized_flashes?
    flashes_count == 100
  end

  def flashes_count
    levels.reduce(0) { |count, row| count + row.count { _1 == 0} }
  end
end


def solve_part1(input = nil)
  with(input) do |io|
    solver = DumboOctopus.new(io.readlines)
    solver.part1
  end
end

def solve_part2(input = nil)
  with(input) do |io|
    solver = DumboOctopus.new(io.readlines)
    solver.part2
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

    puts "==== PART #{part} ===="
    realtime = Benchmark.realtime do
      Timeout::timeout(TIMEOUT_SECONDS) do
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
