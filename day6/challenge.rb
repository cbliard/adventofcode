# frozen_string_literal: true
require 'rspec'
require 'timeout'

PART_1_EXAMPLE_SOLUTION = 5934
PART_2_EXAMPLE_SOLUTION = 26984457539

RSpec.describe "Day 6" do
  let(:sample_input) do
    <<~INPUT
    3,4,3,1,2
    INPUT
  end

  it "has sample input ready" do
    expect(sample_input).not_to match(/copy_sample_input_here/)
  end

  describe 'next_day' do
    it 'subs 1 to each age' do
      expect(next_day([1,2,3,4,5,6,7,8])).to eq([0,1,2,3,4,5,6,7])
    end

    context 'when age is 0' do
      it 'reset age to 6 and add a new lanternfish of age 8' do
        expect(next_day([0])).to eq([6,8])
      end

      it 'adds new lanternfishes at the end' do
        expect(next_day([0, 0, 0])).to eq([6, 6, 6, 8, 8, 8])
      end
    end
  end

  describe 'next_n_days' do
    it 'runs next_day n times' do
      expect(next_n_days(1, [1,2,3,4,5,6,7,8])).to eq([0,1,2,3,4,5,6,7])
      expect(next_n_days(2, [1,2,3,4,5,6,7,8])).to eq([6,0,1,2,3,4,5,6,8])
      expect(next_n_days(3, [1,2,3,4,5,6,7,8])).to eq([5,6,0,1,2,3,4,5,7,8])
    end
  end

  describe 'to_population' do
    it 'converts the ages vector into a population array' do
      expect(to_population([0])).to eq([1,0,0,0,0,0,0,0,0])
      expect(to_population([0,1,2,3,4,5,6,7,8])).to eq([1,1,1,1,1,1,1,1,1])
      expect(to_population([1,1,1,3,3,3,8,7,8])).to eq([0,3,0,3,0,0,0,1,2])
    end
  end

  describe 'next_population' do
    it 'adds newborns to the population and resets the parents to 6th day' do
      expect(next_population([0,1,0,0,0,0,0,0,0])).to eq([1,0,0,0,0,0,0,0,0])
      expect(next_population([1,0,0,0,0,0,0,0,0])).to eq([0,0,0,0,0,0,1,0,1])
      expect(next_population([4,5,6,7,8,9,1,2,3])).to eq([5,6,7,8,9,1,6,3,4])
    end

    context 'when given days parameter' do
      it 'runs it the given number of days' do
        expect(next_population([0,0,0,0,1,0,0,0,0], 1)).to eq([0,0,0,1,0,0,0,0,0])
        expect(next_population([0,0,0,0,1,0,0,0,0], 2)).to eq([0,0,1,0,0,0,0,0,0])
        expect(next_population([0,0,0,0,1,0,0,0,0], 3)).to eq([0,1,0,0,0,0,0,0,0])
        expect(next_population([0,0,0,0,1,0,0,0,0], 4)).to eq([1,0,0,0,0,0,0,0,0])
        expect(next_population([0,0,0,0,1,0,0,0,0], 5)).to eq([0,0,0,0,0,0,1,0,1])
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

def to_population(ages)
  population = Array.new(9, 0)
  ages.each { |age| population[age] += 1 }
  population
end

def next_population(population, n = 1)
  while n > 0
    n -= 1
    newborns = population.shift
    population[6] += newborns
    population << newborns
  end
  population
end

def next_day_v1(ages)
  next_ages = []
  new_lanternfishes_count = 0
  ages.each do |age|
    if age == 0
      new_age = 6
      new_lanternfishes_count += 1
    else
      new_age = age - 1
    end
    next_ages << new_age
  end
  next_ages + Array.new(new_lanternfishes_count, 8)
end

def next_day(ages)
  count = ages.length
  i = 0
  while i < count
    age = ages[i]
    ages << 8 if age == 0
    ages[i] = age == 0 ? 6 : age - 1
    i += 1
  end
  ages
end

def next_n_days(n, ages)
  return ages if n <= 0

  next_n_days(n-1, next_day(ages))
end

def solve_part1(input = nil)
  with(input) do |io|
    ages = io.readlines.first.split(",").map(&:to_i)
    result = next_n_days(80, ages)
    result.count
  end
end

def solve_part2(input = nil)
  with(input) do |io|
    ages = io.readlines.first.split(",").map(&:to_i)
    population = to_population(ages)
    next_population(population, 256).sum
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
    c.around(:each) do |example|
      Timeout::timeout(3) {
        example.run
      }
    end
  end
  rspec_result = RSpec::Core::Runner.run([])

  if rspec_result == 0
    puts "part 1 solution: #{solve_part1}" if PART_1_EXAMPLE_SOLUTION
    puts "part 2 solution: #{solve_part2}" if PART_2_EXAMPLE_SOLUTION
  end
end
