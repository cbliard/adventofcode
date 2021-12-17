# frozen_string_literal: true

require "benchmark"
require "rspec"
require "set"
require "timeout"

PART_1_EXAMPLE_SOLUTION = 45
PART_2_EXAMPLE_SOLUTION = 112
TIMEOUT_SECONDS = 30

RSpec.describe "Day 17" do
  let(:sample_input) do
    <<~INPUT
      target area: x=20..30, y=-10..-5
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

def hit?(dx, dy, tx_range, ty_range)
  x = y = 0
  while y >= ty_range.min && x <= tx_range.max
    y += dy
    x += dx
    return true if ty_range.cover?(y) && tx_range.cover?(x)

    dy -= 1
    dx -= 1 if dx > 0
  end
  false
end

def solve_part1(input = nil)
  with(input) do |io|
    _tx1, _tx2, ty1, ty2 = io.readlines.first.scan(/-?\d+/).map(&:to_i)
    dy = [ty1, ty2].map(&:abs).max.pred
    dy * (dy + 1) / 2
  end
end

def solve_part2(input = nil)
  with(input) do |io|
    tx1, tx2, ty1, ty2 = io.readlines.first.scan(/-?\d+/).map(&:to_i)
    ty_range = Range.new(*[ty1, ty2].sort)
    tx_range = Range.new(*[tx1, tx2].sort)
    dymax = ty_range.min.abs.pred
    dymin = ty_range.min
    dxmax = tx_range.max
    dxmin = ((Math.sqrt(tx_range.min) - 1) / 2).round
    (dxmin..dxmax).to_a.product((dymin..dymax).to_a)
      .count { |dx, dy| hit?(dx, dy, tx_range, ty_range) }
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
