# frozen_string_literal: true
require 'benchmark'
require 'rspec'
require 'timeout'

PART_1_EXAMPLE_SOLUTION = 17
PART_2_EXAMPLE_SOLUTION = <<~SQUARE.strip
  #####
  #   #
  #   #
  #   #
  #####
SQUARE
TIMEOUT_SECONDS = 5

RSpec.describe "Day 13" do
  let(:sample_input) do
    <<~INPUT
    6,10
    0,14
    9,10
    0,3
    10,4
    4,11
    6,0
    6,12
    4,1
    0,13
    10,12
    3,4
    3,0
    8,4
    1,10
    2,14
    8,10
    9,0

    fold along y=7
    fold along x=5
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

def fold_x(point, fold_coord)
  x, y = point
  if x < fold_coord
    point
  else
    [fold_coord - (x - fold_coord), y]
  end
end

def fold_y(point, fold_coord)
  x, y = point
  if y < fold_coord
    point
  else
    [x, fold_coord - (y - fold_coord)]
  end
end

def fold(point, fold)
  direction, fold_coord = fold
  if direction == "fold along y"
    fold_y(point, fold_coord)
  else
    fold_x(point, fold_coord)
  end
end

def solve_part1(input = nil)
  with(input) do |io|
    folds, points = io.readlines
      .map(&:strip)
      .reject(&:empty?)
      .partition { |line| line.start_with?("fold") }
    folds = folds
      .map { |fold| fold.split("=").then { |(direction, fold_coord)| [direction, fold_coord.to_i] } }
    points = points
      .map { |s| s.split(",").map(&:to_i)}

    fold = folds.first
    points.map { fold(_1, fold) }
      .uniq
      .count
  end
end

def grid(points)
  xmax = points.map { _1[0] }.max + 1
  ymax = points.map { _1[1] }.max + 1
  output = Array.new(ymax) { Array.new(xmax, " ") }
  points.each { |(x, y)| output[y][x] = "#" }
  output.map(&:join).join("\n")
end

def solve_part2(input = nil)
  with(input) do |io|
    folds, points = io.readlines
      .map(&:strip)
      .reject(&:empty?)
      .partition { |line| line.start_with?("fold") }
    folds = folds
      .map { |fold| fold.split("=").then { |(direction, fold_coord)| [direction, fold_coord.to_i] } }
    points = points
      .map { |s| s.split(",").map(&:to_i)}

    folded_points = folds.reduce(points) { |points, fold| points.map { fold(_1, fold) } }.uniq
    grid(folded_points)
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
        puts "answer: \n#{send(solver)}"
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
