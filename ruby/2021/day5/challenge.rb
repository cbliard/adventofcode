# frozen_string_literal: true

require "rspec"

PART_1_EXAMPLE_SOLUTION = 5
PART_2_EXAMPLE_SOLUTION = 12

RSpec.describe "Day 5" do
  let(:sample_input) do
    <<~INPUT
      0,9 -> 5,9
      8,0 -> 0,8
      9,4 -> 3,4
      2,2 -> 2,1
      7,0 -> 7,4
      6,4 -> 2,0
      0,9 -> 2,9
      3,4 -> 1,4
      0,0 -> 8,8
      5,5 -> 8,2
    INPUT
  end

  it "has sample input ready" do
    expect(sample_input).not_to match(/copy_sample_input_here/)
  end

  describe "expand" do
    it "expands each horizontal segment into coordinates" do
      expect(expand("0,9 -> 1,9")).to eq([[0, 9], [1, 9]])
      expect(expand("0,9 -> 2,9")).to eq([[0, 9], [1, 9], [2, 9]])
      expect(expand("0,9 -> 5,9")).to eq([[0, 9], [1, 9], [2, 9], [3, 9], [4, 9], [5, 9]])
    end

    it "expands each horizontal segment into coordinates backwards" do
      expect(expand("1,9 -> 0,9")).to eq([[1, 9], [0, 9]])
      expect(expand("2,9 -> 0,9")).to eq([[2, 9], [1, 9], [0, 9]])
      expect(expand("5,9 -> 0,9")).to eq([[5, 9], [4, 9], [3, 9], [2, 9], [1, 9], [0, 9]])
    end

    it "expands each vertical segment into coordinates" do
      expect(expand("0,0 -> 0,2")).to eq([[0, 0], [0, 1], [0, 2]])
    end

    it "expands each vertical segment into coordinates backwards" do
      expect(expand("0,2 -> 0,0")).to eq([[0, 2], [0, 1], [0, 0]])
    end

    it "does not expand diagonally" do
      expect(expand("0,2 -> 2,0")).to eq([])
      expect(expand("2,0 -> 0,2")).to eq([])
      expect(expand("0,0 -> 2,2")).to eq([])
      expect(expand("2,2 -> 0,0")).to eq([])
    end
  end

  describe "expand_with_diags" do
    it "expands diagonally in each direction" do
      expect(expand_with_diags("0,2 -> 2,0")).to eq([[0, 2], [1, 1], [2, 0]])
      expect(expand_with_diags("2,0 -> 0,2")).to eq([[2, 0], [1, 1], [0, 2]])
      expect(expand_with_diags("0,0 -> 2,2")).to eq([[0, 0], [1, 1], [2, 2]])
      expect(expand_with_diags("2,2 -> 0,0")).to eq([[2, 2], [1, 1], [0, 0]])
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

def fromto(a, b, size)
  if a == b
    Array.new(size, a)
  elsif a < b
    a.upto(b)
  else
    a.downto(b)
  end
end

def size(x1, y1, x2, y2)
  if x1 < x2
    x2 - x1 + 1
  elsif x2 < x1
    x1 - x2 + 1
  elsif y1 < y2
    y2 - y1 + 1
  elsif y2 < y1
    y1 - y2 + 1
  else
    1
  end
end

def expand(entry)
  coordinates = entry
    .split(" -> ")
    .map { _1.split(",").map(&:to_i) }
  case coordinates
  in [x, y1], [^x, y2]
    ys = y1 < y2 ? y1.upto(y2) : y1.downto(y2)
    ys.map { [x, _1] }
  in [x1, y], [x2, ^y]
    xs = x1 < x2 ? x1.upto(x2) : x1.downto(x2)
    xs.map { [_1, y] }
  else
    []
  end
end

def expand_with_diags(entry)
  coordinates = entry
    .split(" -> ")
    .map { _1.split(",").map(&:to_i) }
  (x1, y1), (x2, y2) = coordinates
  size = size(x1, y1, x2, y2)
  xs = fromto(x1, x2, size)
  ys = fromto(y1, y2, size)
  xs.zip(ys)
end

def solve_part1(input = nil)
  with(input) do |io|
    io.readlines
      .flat_map { expand(_1) }
      .tally
      .filter { |_coordinates, count| count > 1 }
      .count
  end
end

def solve_part2(input = nil)
  with(input) do |io|
    io.readlines
      .flat_map { expand_with_diags(_1) }
      .tally
      .filter { |_coordinates, count| count > 1 }
      .count
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

if $0 == __FILE__
  RSpec.configure do |c|
    c.fail_fast = true
    c.formatter = "documentation"
  end
  rspec_result = RSpec::Core::Runner.run([])
  if rspec_result == 0
    puts "part 1 solution: #{solve_part1}" if PART_1_EXAMPLE_SOLUTION
    puts "part 2 solution: #{solve_part2}" if PART_2_EXAMPLE_SOLUTION
  end
end
