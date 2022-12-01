# frozen_string_literal: true

require "benchmark"
require "rspec"
require "set"
require "timeout"

PART_1_EXAMPLE_SOLUTION = 35
PART_2_EXAMPLE_SOLUTION = 3351
TIMEOUT_SECONDS = 30

RSpec.describe "Day 20" do
  let(:sample_input) do
    <<~INPUT
      ..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..###..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###.######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#..#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#......#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#.....####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#.......##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#

      #..#.
      #....
      ##..#
      ..#..
      ..###
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

class TrenchMap
  attr_reader :input

  def initialize(input)
    @input = input
  end

  def algo
    @algo ||= @input.first.chars.map { _1 == "#" ? 1 : 0 }
  end

  def initial_image
    @initial_image ||= input[2..].map { |row| row.strip.chars.map { _1 == "#" ? 1 : 0 } }
  end

  def extend_image(image, background)
    empty_row = Array.new(image.first.length + 4, background)
    [
      empty_row,
      empty_row,
      *image.map { [background, background] + _1 + [background, background] },
      empty_row,
      empty_row
    ]
  end

  def enhance(n)
    image = initial_image
    background = 0
    n.times do
      image = extend_image(image, background).each_cons(3).map do |r1, r2, r3|
        r1.each_cons(3).zip(r2.each_cons(3), r3.each_cons(3)).map do |pixels|
          index = pixels.flatten.reduce { |acc, bit| (acc << 1) + bit }
          algo[index]
        end
      end
      background = background == 0 ? algo.first : algo.last
    end
    image
  end

  def part1
    enhance(2).flatten.count(1)
  end

  def part2
    enhance(50).flatten.count(1)
  end
end

def solve_part1(input = nil)
  with(input) do |io|
    TrenchMap.new(io.readlines).part1
  end
end

def solve_part2(input = nil)
  with(input) do |io|
    TrenchMap.new(io.readlines).part2
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
