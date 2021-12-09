# frozen_string_literal: true
require 'benchmark'
require 'rspec'
require 'set'
require 'timeout'

PART_1_EXAMPLE_SOLUTION = 15
PART_2_EXAMPLE_SOLUTION = 1134
TIMEOUT_SECONDS = 5

RSpec.describe "Day 9" do
  let(:sample_input) do
    <<~INPUT
    2199943210
    3987894921
    9856789892
    8767896789
    9899965678
    INPUT
  end

  it "has sample input ready" do
    expect(sample_input).not_to match(/copy_sample_input_here/)
  end

  describe "solve_part1" do
    subject { solve_part1(sample_input).to_s }

    it { is_expected.to eq(PART_1_EXAMPLE_SOLUTION.to_s) }
  end

  describe "merge_adjacent_regions" do
    it 'connects the regions together' do
      initial = [
        ["a", "a"],
        ["b", 9],
      ]
      final = [
        ["a", "a"],
        ["a", 9],
      ]
      expect(merge_adjacent_regions(initial)).to eq(final)
    end
  end

  describe "to_basins" do
    it 'works if connected later' do
      grid = <<~INPUT
        2199943210
        3987894921
        9856789899
        8767896798
        9899965678
      INPUT
      grid = grid.split("\n").map { _1.strip.split("").map(&:to_i) }
      result = to_basins(grid).map { |line| line.map(&:to_s).join }
      .join("\n")
      expected_result = <<~RESULT.strip
        aa999bbbbb
        a9ccc9b9bb
        9ccccc9d99
        ccccc9dd9d
        9c999ddddd
      RESULT
      expect(result).to eq(expected_result)
    end
  end

  if PART_2_EXAMPLE_SOLUTION
    describe "solve_part2" do
      subject { solve_part2(sample_input).to_s }

      it { is_expected.to eq(PART_2_EXAMPLE_SOLUTION.to_s) }
    end
  end
end

def adjacents(grid, x, y)
  [[x, y-1], [x-1, y], [x+1, y], [x, y+1]]
    .map { |xx, yy|
      next if xx < 0 || y < 0
      grid.dig(xx, yy)
    }
    .compact
end

def each_grid_point(grid)
  nb_rows = grid.length
  nb_cols = grid.first.length
  irow = 0
  while irow < nb_rows
    icol = 0
    while icol < nb_cols
      yield irow, icol
      icol += 1
    end
    irow += 1
  end
end

def basin?(h)
  h.is_a?(String)
end

def lowpoints(grid)
  lowpoints = []
  each_grid_point(grid) do |irow, icol|
    if adjacents(grid, irow, icol).all? { |height| height > grid[irow][icol] }
      lowpoints << grid[irow][icol]
    end
  end
  lowpoints
end

def to_basins(grid)
  map = Array.new(grid.length) { Array.new(grid.first.length) }
  next_basin = nil
  marked = []
  basin = nil
  irow = 0
  grid.each do |line|
    icol = 0
    line.each do |height|
      if height == 9
        map[irow][icol] = 9
        marked.each do |row, col|
          if basin.nil?
            next_basin = next_basin&.succ || "a"
            basin = next_basin
          end
          map[row][col] = basin
        end
        basin = nil
        marked = []
      else
        marked << [irow, icol]
        basin ||= [map[irow][icol-1], map[irow-1][icol]].find { |x| basin?(x) }
      end
      icol += 1
    end
    marked.each do |row, col|
      if basin.nil?
        next_basin = next_basin&.succ || "a"
        basin = next_basin
      end
      map[row][col] = basin
    end
    basin = nil
    marked = []
    irow += 1
  end
  merge_adjacent_regions(map)
end

def merge_adjacent_regions(grid)
  mapping = grid
    .transpose
    .flat_map do |column|
      column = column.dup
      groups = []
      while (idx = column.index(9))
        groups << column.shift(idx)
        column.shift
      end
      groups << column
      groups
        .reject { _1.length <= 1 }
        .map { Set.new(_1) }
    end
    .reduce([]) do |all_groups, group|
      matching_group = all_groups.find { group.intersect?(_1) }
      if matching_group
        matching_group.merge(group)
      else
        all_groups << group
      end
      all_groups
    end
    .reduce({}) do |mapping, group|
      head, *tail = group.to_a.sort
      tail.each { mapping[_1] = head }
      mapping
    end
  grid.map do |row|
    row.map { |x| mapping.fetch(x, x) }
  end
end

def solve_part1(input = nil)
  with(input) do |io|
    grid = io.readlines.map { _1.strip.split("").map(&:to_i) }
    lowpoints(grid)
      .map { |v| v + 1 }
      .sum
  end
end

def solve_part2(input = nil)
  with(input) do |io|
    grid = io.readlines.map { _1.strip.split("").map(&:to_i) }
    m = to_basins(grid)
    (a, b, c) = to_basins(grid)
      .flatten
      .reject { |h| h == 9 }
      .tally
      .values
      .sort
      .last(3)
    a * b * c
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

def to_string(grid)
  grid.map { |line| line.map(&:to_s).join }
    .join("\n")
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
