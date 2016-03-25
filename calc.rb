require 'benchmark'

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

def process_input
  n = ARGV[0].to_i
  m = ARGV[1].to_i
  puts "Calculate N = #{n} M = #{m}"
  bm = Benchmark.measure do
    puts "Result = #{reference_calculate(n, m)}"
  end
  puts bm
end

def build_check_table(n)
  min_m = 1
  max_m = 6 * n
  (min_m..max_m).each do |m|
    puts "N = #{n} M = #{m} Result = #{reference_calculate(n, m)}"
  end
end

def run_test_case(n, m, expected_result)
  result = reference_calculate(n, m)
  if result == expected_result
    puts "OK: N = #{n} M = #{m} Result = #{result}"
  else
    puts "FAIL: N = #{n} M = #{m} Result = #{result} Expected = #{expected_result}"
  end
end

# run_test_case(1, 1, Rational(1) / Rational(6))
# run_test_case(1, 2, Rational(1) / Rational(6))
# run_test_case(1, 3, Rational(1) / Rational(6))
# run_test_case(1, 4, Rational(1) / Rational(6))
# run_test_case(1, 5, Rational(1) / Rational(6))
# run_test_case(1, 6, Rational(1) / Rational(6))
#
# run_test_case(2, 1, Rational(0))
# run_test_case(2, 2, Rational(1) / Rational(36))
# run_test_case(2, 3, Rational(2) / Rational(36))
# run_test_case(2, 4, Rational(3) / Rational(36))
# run_test_case(2, 5, Rational(4) / Rational(36))
# run_test_case(2, 6, Rational(5) / Rational(36))
# run_test_case(2, 7, Rational(6) / Rational(36))
# run_test_case(2, 8, Rational(5) / Rational(36))
# run_test_case(2, 9, Rational(4) / Rational(36))
# run_test_case(2, 10, Rational(3) / Rational(36))
# run_test_case(2, 11, Rational(2) / Rational(36))
# run_test_case(2, 12, Rational(1) / Rational(36))

build_check_table(1)

build_check_table(3)
# process_input
