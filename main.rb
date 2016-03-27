#!/usr/bin/env ruby
require 'benchmark'
require 'erb'

# reference implemenration based on generating all permutations with repetition
# it's a good instrument for validating results of optimized implementation
def reference_calculate(n, m)
  ms = [1,2,3,4,5,6].repeated_permutation(n).map do |attempt|
    attempt.reduce(:+)
  end.reduce(Hash.new(0)) do |acc, el|
    acc[el] += 1
    acc
  end
  Rational(ms[m]) / Rational(6 ** n)
end

# Implenentation based on computing number of compositions of M with N parts where all parts lie in [1, 6]
# Formula is stolen here http://math.stackexchange.com/questions/1598696/what-is-the-number-of-weak-compositions-of-n-with-k-parts-and-restricted-size-of
def optimized_calculate(n, m)
  return 0 if m < n || m > 6 * n
  compositions = (0..n).map do |i|
    (-1)**i * C_n_k(i, n) * C_n_k(n - 1, m - n * (1 - 1) + i * (1 - 6 - 1) - 1)
  end.reduce(:+)
  Rational(compositions) / Rational(6**n)
end

def fac(x)
  return 1 if x == 0
  (1..x).reduce(:*)
end

def C_n_k(k, n)
  return 0 if k < 0 || k > n
  fac(n) / (fac(k) * fac(n - k))
end

def build_check_table(n)
  min_m = n
  max_m = 6 * n
  (min_m..max_m).map do |m|
    ref_result = reference_calculate(n, m)
    calc_result = optimized_calculate(n, m)
    if ref_result == calc_result
      [true, { n: n, m: m, result: calc_result }]
    else
      [false, { n: n, m: m, result: calc_result, expected_result: ref_result }]
    end
  end
end

def report_check_results(table)
  table.each do |(status, report)|
    if status
      puts "OK: N = #{report[:n]}, M = #{report[:m]}, Result = #{report[:result]}"
    else
      puts "FAIL: N = #{report[:n]}, M = #{report[:m]}, Result = #{report[:result]}, Expected result = #{report[:expected_result]}"
    end
  end
end

def run_test
  report_check_results(build_check_table(1))
  report_check_results(build_check_table(2))
  report_check_results(build_check_table(3))
  report_check_results(build_check_table(4))
  report_check_results(build_check_table(5))
  report_check_results(build_check_table(6))
end

def run_calc
  n = ARGV[1].to_i
  m = ARGV[2].to_i
  puts "Calculate N = #{n}, M = #{m}"
  bm = Benchmark.measure do
    result = optimized_calculate(n, m)
    puts "Result(Rational) = #{result}"
    puts "Result(Float) = #{result.to_f}"
  end
  puts "Measurement = #{bm}"
end

def run_help
  filename = __FILE__
  puts ERB.new(DATA.read).result(binding)
end

if ARGV[0] == 'test'
  run_test
elsif ARGV[0] == 'calc'
  run_calc
else
  run_help
end

__END__
NAME
    <%= File.basename(filename) %> - calculates probability

SYNOPSYS
    ruby <%= filename %> COMMAND [ARGS]

DESCRIPTION
    test - Run tests. Tests compare results of optimized implementation with results of reference implementation
    ruby <%= filename %> test

    calc N M - Run calculation for particular N and M. It will output results and measurement (using ruby's Benchmark)
    ruby <%= filename %> calc 300 500
