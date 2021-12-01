#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rspec'

RSpec.describe "count_sonar_depth_increases" do
  it "returns the number of times the depth increases" do
    input = <<~DEPTHS
      199
      200
      208
      210
      200
      207
      240
      269
      260
      263
    DEPTHS
    expect(count_sonar_depth_increases(StringIO.new(input))).to eq(7)
  end
end

RSpec.describe "count_sonar_depth_sliding_increases" do
  it "returns the number of times the depth increases with a sampling window of 3 measures" do
    input = <<~DEPTHS
      199
      200
      208
      210
      200
      207
      240
      269
      260
      263
    DEPTHS
    expect(count_sonar_depth_sliding_increases(StringIO.new(input))).to eq(5)
  end
end


def count_sonar_depth_increases(io = nil)
  if io.nil?
    return open(File.join(__dir__, "challenge1-input.txt")) { |f| count_sonar_depth_increases(f) }
  end

  io.readlines
    .map(&:to_i)
    .each_cons(2)
    .map { |a, b| { -1 => "increased", 0 => "same", 1 => "decreased" }[a <=> b] }
    .count("increased")
end

def count_sonar_depth_sliding_increases(io = nil)
  if io.nil?
    return open(File.join(__dir__, "challenge1-input.txt")) { |f| count_sonar_depth_sliding_increases(f) }
  end

  io.readlines
    .map(&:to_i)
    .each_cons(3)
    .map(&:sum)
    .each_cons(2)
    .map { |a, b| { -1 => "increased", 0 => "same", 1 => "decreased" }[a <=> b] }
    .count("increased")
end

if $0 == __FILE__
  if ARGV[0] == "run"
    puts "part 1: #{count_sonar_depth_increases}"
    puts "part 2: #{count_sonar_depth_sliding_increases}"
  else
    RSpec::Core::Runner.run([])
  end
end
