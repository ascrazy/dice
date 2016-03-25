require 'benchmark'

# reference implemenration based on permutations
# it's a good instrument for checking results of optimized implementation
def reference_calculate(n, m)
  ms = [1,2,3,4,5,6].repeated_permutation(n).map do |attempt|
    attempt.reduce(:+)
  end.reduce(Hash.new(0)) do |acc, el|
    acc[el] += 1
    acc
  end
  Rational(ms[m]) / Rational(6 ** n)
end

def optimized_calculate(n, m)
  min_number = n
  max_number = 6 * n
  variants = if m < min_number || m > max_number
    0
  elsif m <= (max_number + min_number) / 2
    m - min_number + 1
  else
    max_number - m + 1
  end

  Rational(variants) / Rational(6 ** n)
end

def build_check_table(n)
  min_m = 1
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

def run_test_cases
  report_check_results(build_check_table(1))
  report_check_results(build_check_table(2))
  report_check_results(build_check_table(3))
end

def main
  if ARGV[0] && ARGV[1]
    n = ARGV[0].to_i
    m = ARGV[1].to_i
    puts "Calculate N = #{n}, M = #{m}"
    bm = Benchmark.measure do
      result = optimized_calculate(n, m)
      puts "Result = #{result}"
    end
    puts "Measurement = #{bm}"
  else
    run_test_cases
  end
end

main
