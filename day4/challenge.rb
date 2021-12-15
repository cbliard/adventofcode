# frozen_string_literal: true

require "rspec"
require "set"

PART_1_EXAMPLE_SOLUTION = 4512
PART_2_EXAMPLE_SOLUTION = 1924

RSpec.describe "Day 4" do
  let(:sample_input) do
    <<~INPUT
      7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

      22 13 17 11  0
       8  2 23  4 24
      21  9 14 16  7
       6 10  3 18  5
       1 12 20 15 19

       3 15  0  2 22
       9 18 13 17  5
      19  8  7 25 23
      20 11 10 24  4
      14 21 16 12  6

      14 21 17 24  4
      10 16 15  9 19
      18  8 23 26 20
      22 11 13  6  5
       2  0 12  3  7
    INPUT
  end

  it "has sample input ready" do
    expect(sample_input).not_to match(/copy_sample_input_here/)
  end

  describe "Board" do
    let(:board) do
      Board.new([
        [14, 21, 17, 24, 4],
        [10, 16, 15, 9, 19],
        [18, 8, 23, 26, 20],
        [22, 11, 13, 6, 5],
        [2, 0, 12, 3, 7]
      ])
    end

    describe ".from" do
      it "creates a board from stripped lines" do
        lines = <<~BOARD.split("\n")
          14 21 17 24  4
          10 16 15  9 19
          18  8 23 26 20
          22 11 13  6  5
           2  0 12  3  7
        BOARD
        lines << "    "
        expect(Board.from(lines)).to eq(board)
      end
    end

    describe "#winner?" do
      it "returns false if board does not win with drawn numbers" do
        expect(board.winner?([])).to be_falsy
        expect(board.winner?([])).to be_falsy
      end

      it "returns false if drawn numbers do not match a full board row or column" do
        expect(board.winner?([14, 21, 17, 24])).to be_falsy
        expect(board.winner?([1, 2, 3, 4])).to be_falsy
        expect(board.winner?([14, 21, 17, 24, 10, 16, 15, 7, 12, 3])).to be_falsy
      end

      it "returns true if drawn numbers match a board row" do
        expect(board.winner?([14, 21, 17, 24, 4])).to be_truthy
        expect(board.winner?([10, 16, 15, 9, 19])).to be_truthy
        expect(board.winner?([18, 8, 23, 26, 20])).to be_truthy
        expect(board.winner?([22, 11, 13, 6, 5])).to be_truthy
        expect(board.winner?([2, 0, 12, 3, 7])).to be_truthy
      end

      it "returns true if drawn numbers match a board column" do
        expect(board.winner?([14, 10, 18, 22, 2])).to be_truthy
        expect(board.winner?([21, 16, 8, 11, 0])).to be_truthy
        expect(board.winner?([17, 15, 23, 13, 12])).to be_truthy
        expect(board.winner?([24, 9, 26, 6, 3])).to be_truthy
        expect(board.winner?([4, 19, 20, 5, 7])).to be_truthy
      end
    end

    describe "#score" do
      it "returns the sum of all unmarked board numbers multiplied by last drawn number" do
        drawn_numbers = [7, 4, 9, 5, 11, 17, 23, 2, 0, 14, 21, 24]
        expect(board.score(drawn_numbers)).to eq(4512)
      end
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

class Board
  attr_reader :rows, :columns, :lines

  def initialize(rows)
    @columns = rows.transpose.map { Set.new(_1) }
    @rows = rows.map { Set.new(_1) }
    @lines = @rows + @columns
  end

  def winner?(drawn_numbers)
    lines.any? { |line| line & drawn_numbers == line }
  end

  def score(drawn_numbers)
    board_numbers = @rows.reduce(:+)
    unmarked_numbers = board_numbers - Set.new(drawn_numbers)
    sum = unmarked_numbers.sum
    sum * drawn_numbers.last
  end

  def self.from(lines)
    rows = lines.map(&:strip).reject(&:empty?).map { _1.scan(/[0-9]+/).map(&:to_i) }
    Board.new(rows)
  end

  def ==(other)
    other.class == self.class && other.lines == lines
  end
end

def solve_part1(input = nil)
  with(input) do |io|
    lines = io.readlines
    all_drawn_numbers = lines.shift.split(",").map(&:to_i)
    boards = lines.each_slice(6).map { Board.from(_1) }
    drawn_numbers = []
    while all_drawn_numbers.any?
      drawn_numbers << all_drawn_numbers.shift
      winner = boards.find { |board| board.winner?(drawn_numbers) }
      return winner.score(drawn_numbers) if winner
    end
    "not found"
  end
end

def solve_part2(input = nil)
  with(input) do |io|
    lines = io.readlines
    all_drawn_numbers = lines.shift.split(",").map(&:to_i)
    boards = lines.each_slice(6).map { Board.from(_1) }
    drawn_numbers = []
    while all_drawn_numbers.any? && boards.any?
      drawn_numbers << all_drawn_numbers.shift
      winning_boards, remaining_boards = boards.partition { |board| board.winner?(drawn_numbers) }
      if remaining_boards.empty?
        raise "should be only one board left" unless winning_boards.size == 1
        return winning_boards.first.score(drawn_numbers)
      else
        boards = remaining_boards
      end
    end
    "not found"
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
