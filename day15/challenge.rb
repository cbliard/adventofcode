# frozen_string_literal: true

require "benchmark"
require "rspec"
require "set"
require "timeout"

PART_1_EXAMPLE_SOLUTION = 40
PART_2_EXAMPLE_SOLUTION = 315
TIMEOUT_SECONDS = 30

RSpec.describe "Day 15" do
  let(:sample_input) do
    <<~INPUT
      1163751742
      1381373672
      2136511328
      3694931569
      7463417111
      1319128137
      1359912421
      3125421639
      1293138521
      2311944581
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

class Chiton
  attr_reader :input, :extended

  def initialize(input, extended: false)
    @input = input.map(&:strip)
    @extended = extended
  end

  def part1
    lowest_total_risk
  end

  def part2
    lowest_total_risk
  end

  def origin
    [0, 0]
  end

  def destination
    [xmax - 1, ymax - 1]
  end

  def neighbors(position)
    x, y = position
    [
      [x, y + 1], [x + 1, y], [x - 1, y], [x, y - 1]
    ].reject { |x, y| x < 0 || y < 0 || x >= xmax || y >= ymax }
  end

  def lowest_total_risk
    visited = {}
    reachable = {origin => 0}
    c = 0
    pp destination
    output = lambda { |v| v == 97 }
    while reachable.any?

      puts "-----------------" if output.call(c)
      c += 1
      pp visited if output.call(c)
      lowest_risk_position, total_risk = reachable.min_by { |_, level| level }
      puts c if lowest_risk_position == destination
      return total_risk if lowest_risk_position == destination

      visited[lowest_risk_position] = total_risk
      reachable.delete(lowest_risk_position)
      reachable = neighbors(lowest_risk_position)
        .reject { |position| visited.key?(position) }
        .map { |position| [position, total_risk + risk(position)] }
        .to_h
        .merge(reachable) { |_, r1, r2| [r1, r2].min }
      pp reachable if output.call(c)
    end
  end

  def risk(position)
    xtile, x = position[1].divmod(xtile_size)
    ytile, y = position[0].divmod(ytile_size)
    risk = risk_map[x][y] + xtile + ytile
    risk -= 9 if risk > 9
    risk
  end

  def risk_map
    @risk_map ||= input.map { _1.chars.map(&:to_i) }
  end

  def xtile_size
    @xtile_size ||= input.first.length
  end

  def ytile_size
    @ytile_size ||= input.length
  end

  def xmax
    @xmax ||= xtile_size * stretch
  end

  def ymax
    @ymax ||= ytile_size * stretch
  end

  def stretch
    extended ? 5 : 1
  end

  def cavern_risk
    return @cavern if @cavern

    @cavern = []
    indices.map do |position|
      cavern[position] = @input
    end
    @input
  end
end

def solve_part1(input = nil)
  with(input) do |io|
    Chiton.new(io.readlines).part1
  end
end

def solve_part2(input = nil)
  with(input) do |io|
    Chiton.new(io.readlines, extended: true).part1
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
  if File.open(__FILE__) { _1.grep(/binding.irb\b/) }
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
