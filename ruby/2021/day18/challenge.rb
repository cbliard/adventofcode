# frozen_string_literal: true

require "benchmark"
require "rspec"
require "set"
require "timeout"

PART_1_EXAMPLE_SOLUTION = 4140
PART_2_EXAMPLE_SOLUTION = 3993
TIMEOUT_SECONDS = 30

RSpec.describe "Day 18" do
  let(:sample_input) do
    <<~INPUT
      [[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
      [[[5,[2,8]],4],[5,[[9,9],0]]]
      [6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
      [[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
      [[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
      [[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
      [[[[5,4],[7,7]],8],[[8,3],8]]
      [[9,3],[[9,9],[6,[4,9]]]]
      [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
      [[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
    INPUT
  end

  it "has sample input ready" do
    expect(sample_input).not_to match(/copy_sample_input_here/)
  end

  describe "explode" do
    it "explodes" do
      expect(explode([1, 2])).to eq([1, 2])
      expect(explode([[[[[9, 8], 1], 2], 3], 4])).to eq([[[[0, 9], 2], 3], 4])
      expect(explode([7, [6, [5, [4, [3, 2]]]]])).to eq([7, [6, [5, [7, 0]]]])
      expect(explode([[3, [2, [1, [7, 3]]]], [6, [5, [4, [3, 2]]]]]))
        .to eq([[3, [2, [8, 0]]], [9, [5, [7, 0]]]])
    end
  end

  describe "split" do
    def splitted(p)
      split(p)
      p
    end

    it "splits" do
      expect(splitted([1, 2])).to eq([1, 2])
      expect(splitted([[[10, 1], 2], 3])).to eq([[[[5, 5], 1], 2], 3])
      expect(splitted([[[11, 1], 2], 3])).to eq([[[[5, 6], 1], 2], 3])
      expect(splitted([[[1, 2], 13], 3])).to eq([[[1, 2], [6, 7]], 3])
    end
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

class Array
  def dig_set(index, value)
    raise ArgumentError, "No index given" if index.empty?
    index = index.dup
    last = index.pop
    failed = ->(*) { raise KeyError, "index not found: #{(index << last).inspect}" }
    nested = index.inject(self) { |a, i| a.fetch(i, &failed) }
    nested[last] = value
  end
end

def dig(pair, index)
  index.inject(pair) { |p, i| p[i] if p.respond_to?(:fetch) }
end

def dig_subpair(pair, index)
  index.inject(pair) { |a, i| a[i] if a && a[i].is_a?(Array) }
end

def add(p1, p2)
  [p1, p2]
end

def nested_indexes
  (0..15).to_a.map { ("%04b" % _1).chars.map(&:to_i) }
end

def left(index)
  i = index.rindex(1)
  return unless i

  l = index[0..i]
  l[-1] = 0
  l
end

def right(index)
  i = index.rindex(0)
  return unless i

  r = index[0..i]
  r[-1] = 1
  r
end

def explode(p)
  nested_indexes.each do |index|
    if (pair = dig_subpair(p, index))
      if (l = left(index)) && dig(p, l)
        l << 1 while dig(p, l).is_a?(Array)
        p.dig_set(l, dig(p, l) + pair[0])
      end
      if (r = right(index)) && dig(p, r)
        r << 0 while dig(p, r).is_a?(Array)
        p.dig_set(r, dig(p, r) + pair[1])
      end
      p.dig_set(index, 0)
      return explode(p)
    end
  end
  p
end

def pair?(p)
  p.is_a? Array
end

def split(p)
  queue = [[1], [0]]
  while queue.any?
    index = queue.pop
    value = dig(p, index)
    if pair?(value)
      queue << index + [1]
      queue << index + [0]
    elsif value >= 10
      p.dig_set(index, [value / 2, value - value / 2])
      return true
    end
  end
  false
end

def reduce(p)
  loop do
    explode(p)
    split(p) or break
  end
  p
end

def magnitude(p)
  case p
  when Integer then p
  else 3 * magnitude(p[0]) + 2 * magnitude(p[1])
  end
end

def sum(p1, p2)
  reduce(add(p1, p2))
end

def solve_part1(input = nil)
  with(input) do |io|
    numbers = io.readlines.map { eval _1 }
    summed = numbers.reduce do |acc, p|
      sum(acc, p)
    end
    magnitude(summed)
  end
end

def solve_part2(input = nil)
  with(input) do |io|
    io.readlines
      .then { |numbers| numbers.product(numbers) }
      .reject { _1 == _2 }
      .map { magnitude(sum(eval(_1), eval(_2))) }
      .max
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
