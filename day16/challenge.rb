# frozen_string_literal: true

require "benchmark"
require "rspec"
require "set"
require "timeout"

PART_1_EXAMPLE_SOLUTION = 31
PART_2_EXAMPLE_SOLUTION = 54
TIMEOUT_SECONDS = 30

RSpec.describe "Day 16" do
  let(:sample_input) do
    <<~INPUT
      A0016C880162017C3686B18A3D4780
    INPUT
  end

  it "has sample input ready" do
    expect(sample_input).not_to match(/copy_sample_input_here/)
  end

  describe "decode" do
    it "decodes literal integers" do
      expect(decode("D2FE28")).to eq(Packet.new(version: 6, type: 4, data: 2021))
    end

    it "decodes operator packet with length type ID 0" do
      expect(decode("38006F45291200")).to eq(
        Packet.new(version: 1, type: 6, data: [
          Packet.new(version: 6, type: 4, data: 10),
          Packet.new(version: 2, type: 4, data: 20)
        ])
      )
    end

    it "decodes operator packet with length type ID 1" do
      expect(decode("EE00D40C823060")).to eq(
        Packet.new(version: 7, type: 3, data: [
          Packet.new(version: 2, type: 4, data: 1),
          Packet.new(version: 4, type: 4, data: 2),
          Packet.new(version: 1, type: 4, data: 3)
        ])
      )
    end
  end

  describe "Packet#value" do
    it "can interpret sum packets types" do
      packet =
        Packet.new(version: 7, type: Packet::TYPE_SUM, data: [
          Packet.new(version: 2, type: Packet::TYPE_INTEGER_LITERAL, data: 1),
          Packet.new(version: 2, type: Packet::TYPE_INTEGER_LITERAL, data: 2)
        ])
      expect(packet.value).to eq(3)
      expect(decode("C200B40A82").value).to eq(3)
    end

    it "can interpret sum packets types" do
      packet =
        Packet.new(version: 7, type: Packet::TYPE_PRODUCT, data: [
          Packet.new(version: 2, type: Packet::TYPE_INTEGER_LITERAL, data: 6),
          Packet.new(version: 2, type: Packet::TYPE_INTEGER_LITERAL, data: 9)
        ])
      expect(packet.value).to eq(54)
      expect(decode("04005AC33890").value).to eq(54)
    end

    it "can interpret minimum packets types" do
      packet =
        Packet.new(version: 7, type: Packet::TYPE_MINIMUM, data: [
          Packet.new(version: 2, type: Packet::TYPE_INTEGER_LITERAL, data: 7),
          Packet.new(version: 2, type: Packet::TYPE_INTEGER_LITERAL, data: 8),
          Packet.new(version: 2, type: Packet::TYPE_INTEGER_LITERAL, data: 9)
        ])
      expect(packet.value).to eq(7)
      expect(decode("880086C3E88112").value).to eq(7)
    end

    it "can interpret maximum packets types" do
      packet =
        Packet.new(version: 7, type: Packet::TYPE_MAXIMUM, data: [
          Packet.new(version: 2, type: Packet::TYPE_INTEGER_LITERAL, data: 7),
          Packet.new(version: 2, type: Packet::TYPE_INTEGER_LITERAL, data: 8),
          Packet.new(version: 2, type: Packet::TYPE_INTEGER_LITERAL, data: 9)
        ])
      expect(packet.value).to eq(9)
      expect(decode("CE00C43D881120").value).to eq(9)
    end

    it "can interpret less than packets types" do
      packet =
        Packet.new(version: 7, type: Packet::TYPE_LESS_THAN, data: [
          Packet.new(version: 2, type: Packet::TYPE_INTEGER_LITERAL, data: 5),
          Packet.new(version: 2, type: Packet::TYPE_INTEGER_LITERAL, data: 15)
        ])
      expect(packet.value).to eq(1)
      expect(decode("D8005AC2A8F0").value).to eq(1)
    end

    it "can interpret greater than packets types" do
      packet =
        Packet.new(version: 7, type: Packet::TYPE_GREATER_THAN, data: [
          Packet.new(version: 2, type: Packet::TYPE_INTEGER_LITERAL, data: 5),
          Packet.new(version: 2, type: Packet::TYPE_INTEGER_LITERAL, data: 15)
        ])
      expect(packet.value).to eq(0)
      expect(decode("F600BC2D8F").value).to eq(0)
    end

    it "can interpret equal to packets types" do
      packet =
        Packet.new(version: 7, type: Packet::TYPE_EQUAL_TO, data: [
          Packet.new(version: 2, type: Packet::TYPE_INTEGER_LITERAL, data: 5),
          Packet.new(version: 2, type: Packet::TYPE_INTEGER_LITERAL, data: 15)
        ])
      expect(packet.value).to eq(0)
      expect(decode("9C005AC2F8F0").value).to eq(0)
    end

    it "interprets complex expressions" do
      expect(decode("9C0141080250320F1802104A08").value).to eq(1)
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

class Packet
  attr_reader :version, :type, :data

  TYPE_SUM = 0
  TYPE_PRODUCT = 1
  TYPE_MINIMUM = 2
  TYPE_MAXIMUM = 3
  TYPE_INTEGER_LITERAL = 4
  TYPE_GREATER_THAN = 5
  TYPE_LESS_THAN = 6
  TYPE_EQUAL_TO = 7

  def initialize(version:, type:, data:)
    @version = version
    @type = type
    @data = data
  end

  def value
    case type
    when TYPE_SUM then values.sum
    when TYPE_PRODUCT then values.inject(&:*)
    when TYPE_MINIMUM then values.min
    when TYPE_MAXIMUM then values.max
    when TYPE_INTEGER_LITERAL then data
    when TYPE_LESS_THAN then values.then { |a, b| a < b ? 1 : 0 }
    when TYPE_GREATER_THAN then values.then { |a, b| a > b ? 1 : 0 }
    when TYPE_EQUAL_TO then values.then { |a, b| a == b ? 1 : 0 }
    end
  end

  def values
    data.map(&:value)
  end

  def version_sum
    version + subpackets.sum { _1.version_sum }
  end

  def subpackets
    container? ? data : []
  end

  def literal?
    type == TYPE_INTEGER_LITERAL
  end

  def container?
    type != TYPE_INTEGER_LITERAL
  end

  def ==(other)
    other.class == self.class && other.version == version && other.type == type && other.data == data
  end
end

class Parser
  attr_reader :bits
  attr_accessor :cursor

  LENGTH_TYPE_TOTAL_LENGTH = 0
  LENGTH_TYPE_SUBPACKETS_COUNT = 1

  def initialize(message)
    @bits = [message].pack("H*").unpack1("B*")
    @cursor = 0
  end

  def decode
    decode_packet
  end

  def decode_packet
    version = read_version
    type = read_type
    data =
      if type == Packet::TYPE_INTEGER_LITERAL
        read_integer_literal_value
      else
        length_type = read(1).to_i(2)
        if length_type == LENGTH_TYPE_TOTAL_LENGTH
          length = read(15).to_i(2)
          target = cursor + length
          subpackets = []
          while cursor < target
            subpackets << decode_packet
          end
          subpackets
        else
          packets_count = read(11).to_i(2)
          packets_count.times.map { decode_packet }
        end
      end
    Packet.new(version: version, type: type, data: data)
  end

  def read_version
    read(3).to_i(2)
  end

  def read_type
    read(3).to_i(2)
  end

  def read_integer_literal_value
    to = from = cursor
    to += 5 while bits[to] == "1"
    to += 5
    bits[from...to].chars.each_slice(5).map { _1[1..] }.join.to_i(2)
  ensure
    self.cursor = to
  end

  def read(n)
    from = cursor
    to = cursor + n
    bits[from...to]
  ensure
    self.cursor = to
  end
end

def decode(message)
  Parser.new(message).decode
end

def decode_bits(bits)
  version = bits[0..2].to_i(2)
  type = bits[3..5].to_i(2)
  if type == 4
    decode_string_literal
  end
  i = 6
  i += 5 while bits[i] == "1"
  i += 4
  data = bits[6..i]
  Packet.new(version: version, type: type, data: data)
end

def solve_part1(input = nil)
  with(input) do |io|
    message = io.readlines.first.strip
    packet = decode(message)
    packet.version_sum
  end
end

def solve_part2(input = nil)
  with(input) do |io|
    message = io.readlines.first.strip
    packet = decode(message)
    packet.value
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
