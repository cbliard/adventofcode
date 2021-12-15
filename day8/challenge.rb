# frozen_string_literal: true

require "benchmark"
require "rspec"
require "set"
require "timeout"

PART_1_EXAMPLE_SOLUTION = 26
PART_2_EXAMPLE_SOLUTION = 61229
TIMEOUT_SECONDS = 5

#   0:      1:      2:      3:      4:
#  aaaa    ....    aaaa    aaaa    ....
# b    c  .    c  .    c  .    c  b    c
# b    c  .    c  .    c  .    c  b    c
#  ....    ....    dddd    dddd    dddd
# e    f  .    f  e    .  .    f  .    f
# e    f  .    f  e    .  .    f  .    f
#  gggg    ....    gggg    gggg    ....

#   5:      6:      7:      8:      9:
#  aaaa    aaaa    aaaa    aaaa    aaaa
# b    .  b    .  .    c  b    c  b    c
# b    .  b    .  .    c  b    c  b    c
#  dddd    dddd    ....    dddd    dddd
# .    f  e    f  .    f  e    f  .    f
# .    f  e    f  .    f  e    f  .    f
#  gggg    gggg    ....    gggg    gggg

RSpec.describe "Day 8" do
  let(:sample_input) do
    <<~INPUT
      be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
      edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
      fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
      fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
      aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
      fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
      dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
      bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
      egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
      gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
    INPUT
  end

  it "has sample input ready" do
    expect(sample_input).not_to match(/copy_sample_input_here/)
  end

  describe "count_1478" do
    it "counts the number of times 1, 4, 7, or 8 appear in the four digits output value" do
      expect(count_1478("gcbe")).to eq(1)
      expect(count_1478("cgb")).to eq(1)
      expect(count_1478("cg cg")).to eq(2)
      expect(count_1478("abcdefg")).to eq(1)
      expect(count_1478("cg cg fdcagb cbg")).to eq(3)
    end
  end

  describe "find_digits" do
    it "find digits from input" do
      input = "acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf"
      expect(find_digits(input)).to eq("5353")
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

def count_1478(s)
  s.split(" ")
    .map { |d| {2 => "1", 3 => "7", 4 => "4", 7 => "8"}[d.length] }
    .compact
    .count
end

def find_digits(input)
  patterns, digits = input.split(" | ")
  patterns = patterns.split.map { Set.new(_1chars) }
  digits = digits.split.map { Set.new(_1chars) }

  mapping = {}

  mapping["1"] = patterns.find { |p| p.length == 2 }
  mapping["7"] = patterns.find { |p| p.length == 3 }
  mapping["4"] = patterns.find { |p| p.length == 4 }
  mapping["235"] = patterns.filter { |p| p.length == 5 }
  mapping["069"] = patterns.filter { |p| p.length == 6 }
  mapping["8"] = patterns.find { |p| p.length == 7 }

  mapping["6"] = mapping["069"].find { |p| !p.superset?(mapping["1"]) }
  mapping["9"] = mapping["069"].find { |p| p.superset?(mapping["4"]) }
  mapping["0"] = (mapping["069"] - [mapping["6"]] - [mapping["9"]])[0]

  mapping["3"] = mapping["235"].find { |p| p.superset?(mapping["1"]) }
  mapping["2"] = mapping["235"].find { |p| (p & mapping["4"]).length == 2 }
  mapping["5"] = (mapping["235"] - [mapping["2"]] - [mapping["3"]])[0]

  mapping.invert.values_at(*digits).join
end

def solve_part1(input = nil)
  with(input) do |io|
    io.readlines
      .map { |l| l.split(" | ").last }
      .map { |s| count_1478(s) }
      .sum
  end
end

def solve_part2(input = nil)
  with(input) do |io|
    io.readlines
      .map { |l| find_digits(l).to_i }
      .sum
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

def run_rspec
  RSpec.configure do |c|
    c.fail_fast = true
    c.formatter = "documentation"
    c.around(:each) do |example|
      Timeout.timeout(TIMEOUT_SECONDS) {
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
    [2, PART_2_EXAMPLE_SOLUTION, :solve_part2]
  ].each do |part, part_implemented, solver|
    next unless part_implemented

    puts "==== PART #{part} ===="
    realtime = Benchmark.realtime do
      Timeout.timeout(TIMEOUT_SECONDS) do
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
