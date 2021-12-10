# frozen_string_literal: true
require 'benchmark'
require 'rspec'
require 'timeout'

PART_1_EXAMPLE_SOLUTION = 26397
PART_2_EXAMPLE_SOLUTION = 288957
TIMEOUT_SECONDS = 5

CORRUPTED_SCORES = {
  ")" => 3,
  "]" => 57,
  "}" => 1197,
  ">" => 25137,
}

INCOMPLETE_SCORES = {
  ")" => 1,
  "]" => 2,
  "}" => 3,
  ">" => 4,
}

PAIRS = {
  "(" => ")",
  "[" => "]",
  "{" => "}",
  "<" => ">",
}

RSpec.describe "Day 10" do
  let(:sample_input) do
    <<~INPUT
      [({(<(())[]>[[{[]{<()<>>
      [(()[<>])]({[<{<<[]>>(
      {([(<{}[<>[]}>{[]{[(<()>
      (((({<>}<{<{<>}{[]{[]{}
      [[<[([]))<([[{}[[()]]]
      [{[{({}]{}}([{[{{{}}([]
      {<[[]]>}<{[{[{[]{()[[[]
      [<(<(<(<{}))><([]([]()
      <{([([[(<>()){}]>(<<{{
      <{([{{}}[<[[[<>{}]]]>[]]
    INPUT
  end

  it "has sample input ready" do
    expect(sample_input).not_to match(/copy_sample_input_here/)
  end

  describe 'analyze' do
    it 'return :corrupted when invalid' do
      expect(analyze("(]")).to eq({corrupted: "]"})
    end

    it 'return :incomplete when invalid' do
      expect(analyze("(")).to eq({incomplete: %w")"})
      expect(analyze("([{<")).to eq({incomplete: %w"> } ] )"})
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

def corrupted_score(char)
  CORRUPTED_SCORES[char]
end

def incomplete_score(chars)
  chars.reduce(0) { |score, char| (score * 5) + INCOMPLETE_SCORES[char] }
end

def analyze(line)
  stack = []
  line.chars.each do |char|
    case char
    when "(", "{", "[", "<"
      stack.push(char)
    when ")", "}", "]", ">"
      return {corrupted: char} if char != PAIRS[stack.pop]
    end
  end

  {incomplete: PAIRS.values_at(*stack.reverse)}
end

def solve_part1(input = nil)
  with(input) do |io|
    io.readlines
      .filter_map { analyze(_1)[:corrupted] }
      .reduce(0) { |score, char| score + corrupted_score(char) }
  end
end

def solve_part2(input = nil)
  with(input) do |io|
    io.readlines
      .filter_map { analyze(_1)[:incomplete] }
      .map { incomplete_score(_1) }
      .sort
      .then { |scores| scores[scores.length / 2] }
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
