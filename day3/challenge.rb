# frozen_string_literal: true
require 'rspec'

RSpec.describe "Day 3" do
  let(:sample_input) do
    <<~INPUT
      00100
      11110
      10110
      10111
      10101
      01111
      00111
      11100
      10000
      11001
      00010
      01010
    INPUT
  end

  it "has sample input ready" do
    expect(sample_input).not_to match(/copy_sample_input_here/)
  end

  describe "solve_part1" do
    subject { solve_part1(sample_input).to_s }

    it { is_expected.to eq("198") }
  end

  describe "oxygen_rating" do
    it "returns '' if given empty array" do
      expect(oxygen_rating([])).to eq("")
    end

    it "returns array content if given array with unique number" do
      expect(oxygen_rating(["1"])).to eq("1")
      expect(oxygen_rating(["0"])).to eq("0")
      expect(oxygen_rating(["01"])).to eq("01")
      expect(oxygen_rating(["100101"])).to eq("100101")
    end

    it "returns '1' if have equal numbers of '0' and '1'" do
      expect(oxygen_rating(%w[1 0])).to eq("1")
    end

    it "returns '0' if more '0' than '1'" do
      expect(oxygen_rating(%w[10 01 00])).to eq("01")
    end

    it "returns '1' if more '1' than '0'" do
      expect(oxygen_rating(%w[10 11 00])).to eq("11")
    end

    it "returns a string including 'error' if not unique" do
      expect(oxygen_rating(%w[1 1])).to include("error")
    end
  end

  describe "co2_rating" do
    it "returns '' if given empty array" do
      expect(co2_rating([])).to eq("")
    end

    it "returns array content if given array with unique number" do
      expect(co2_rating(["1"])).to eq("1")
      expect(co2_rating(["0"])).to eq("0")
      expect(co2_rating(["01"])).to eq("01")
      expect(co2_rating(["100101"])).to eq("100101")
    end

    it "returns '0' if have equal numbers of '0' and '1'" do
      expect(co2_rating(%w[1 0])).to eq("0")
    end

    it "returns '0' if less '0' than '1'" do
      expect(co2_rating(%w[10 11 00])).to eq("00")
    end

    it "returns '1' if less '1' than '0'" do
      expect(co2_rating(%w[10 01 00])).to eq("10")
    end
  end

  describe "solve_part2" do
    subject { solve_part2(sample_input).to_s }

    it { is_expected.to eq("230") }
  end
end


def solve_part1(input = nil)
  with(input) do |io|
    lines = io.readlines
    bits_sum = lines.map { _1.strip.split("").map(&:to_i) }
      .transpose
      .map(&:sum)
    gamma_bits = bits_sum.map { |sum| sum > lines.count / 2 ? 1 : 0 }
    epsilon_bits = bits_sum.map { |sum| sum < lines.count / 2 ? 1 : 0 }

    gamma = gamma_bits.map(&:to_s).join.to_i(2)
    epsilon = epsilon_bits.map(&:to_s).join.to_i(2)

    (gamma * epsilon).to_s
  end
end

def rating(numbers, &block)
  return "" if numbers.empty?
  return numbers.first if numbers.count == 1
  return 'error' if numbers.first.empty?

  groups = { "0" => [], "1" => [] }
  numbers.each do |number|
    head, tail = number.split("", 2)
    groups[head] << tail
  end

  digit = block.call(groups["0"].count, groups["1"].count)

  digit + rating(groups[digit], &block)
end

def oxygen_rating(numbers)
  rating(numbers) do |leading_0_count, leading_1_count|
    leading_0_count > leading_1_count ? "0" : "1"
  end
end

def co2_rating(numbers)
  rating(numbers) do |leading_0_count, leading_1_count|
    leading_0_count <= leading_1_count ? "0" : "1"
  end
end

def solve_part2(input = nil)
  with(input) do |io|
    lines = io.readlines
    oxygen_rating = oxygen_rating(lines).to_i(2)
    co2_rating = co2_rating(lines).to_i(2)
    oxygen_rating * co2_rating
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

if $0 == __FILE__
  RSpec.configure do |c|
    c.fail_fast = true
    c.formatter = "documentation"
  end
  rspec_result = RSpec::Core::Runner.run([])
  if rspec_result == 0
    puts "part 1 solution: #{solve_part1}"
    puts "part 2 solution: #{solve_part2}"
  end
end
