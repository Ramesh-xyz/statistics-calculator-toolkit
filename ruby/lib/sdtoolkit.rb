# frozen_string_literal: true

require_relative "sdtoolkit/version"

# Standard deviation, variance, sum of squares, relative standard deviation
# and coefficient of variation with explicit population/sample formulas.
#
# Every method takes an Enumerable of real numbers (Integer, Float, Rational,
# BigDecimal). Values are converted to Float. nil, true/false, strings,
# complex numbers, NaN and infinities raise StatisticsError.
#
# Variance uses a corrected two-pass algorithm with Neumaier compensated
# summation; the shortcut sum(x**2) - n*mean**2 is never used.
module SDToolkit
  # Raised for empty, too-short or invalid input.
  class StatisticsError < ArgumentError; end

  # Result of SDToolkit.describe. rsd_percent is nil when the mean is zero.
  Summary = Struct.new(
    :n, :mean, :minimum, :maximum, :range, :sum_of_squares,
    :variance, :stdev, :rsd_percent, :population,
    keyword_init: true
  )

  module_function

  # Arithmetic mean.
  def mean(data)
    values = to_floats(data)
    neumaier_sum(values) / values.size
  end

  # Sum of squared deviations from the mean, SS = sum((x - mean)**2).
  def sum_of_squares(data)
    mean_and_ss(to_floats(data))[1]
  end

  # Population variance, SS / N.
  def population_variance(data)
    values = to_floats(data)
    mean_and_ss(values)[1] / values.size
  end

  # Sample variance with Bessel's correction, SS / (n - 1). Needs n >= 2.
  def sample_variance(data)
    values = to_floats(data)
    need_two(values.size)
    mean_and_ss(values)[1] / (values.size - 1)
  end

  # Population standard deviation, sqrt(SS / N).
  def population_stdev(data)
    Math.sqrt(population_variance(data))
  end

  # Sample standard deviation, sqrt(SS / (n - 1)). Needs n >= 2.
  def sample_stdev(data)
    Math.sqrt(sample_variance(data))
  end

  # Standard deviation divided by |mean|, as a ratio (0.05 means 5 %).
  # Raises StatisticsError when the mean is zero.
  def coefficient_of_variation(data, population: false)
    values = to_floats(data)
    n = values.size
    need_two(n) unless population
    m, ss = mean_and_ss(values)
    raise StatisticsError, "mean is zero; relative dispersion is undefined" if m.zero?

    Math.sqrt(ss / (population ? n : n - 1)) / m.abs
  end

  # Relative standard deviation in percent: 100 * SD / |mean|.
  def relative_std_dev(data, population: false)
    100.0 * coefficient_of_variation(data, population: population)
  end

  # Summary of location and spread. population: false (default) uses n - 1.
  def describe(data, population: false)
    values = to_floats(data)
    n = values.size
    need_two(n) unless population
    m, ss = mean_and_ss(values)
    var = ss / (population ? n : n - 1)
    sd = Math.sqrt(var)
    lo, hi = values.minmax
    Summary.new(
      n: n, mean: m, minimum: lo, maximum: hi, range: hi - lo,
      sum_of_squares: ss, variance: var, stdev: sd,
      rsd_percent: m.zero? ? nil : 100.0 * (sd / m.abs),
      population: population
    ).freeze
  end

  def to_floats(data)
    raise StatisticsError, "expected an Enumerable of numbers, got a string" if data.is_a?(String)
    raise StatisticsError, "expected an Enumerable of numbers, got #{data.inspect}" unless data.respond_to?(:each_with_index)

    values = []
    data.each_with_index do |x, i|
      case x
      when nil
        raise StatisticsError, "item #{i}: nil (missing value); remove or fill it before computing"
      when true, false
        raise StatisticsError, "item #{i}: booleans are not numbers (#{x})"
      when String
        raise StatisticsError, "item #{i}: strings are not accepted (#{x.inspect}); convert with Float() first"
      end
      unless x.is_a?(Numeric) && x.real?
        raise StatisticsError, "item #{i}: #{x.inspect} is not a real number"
      end

      f = x.to_f
      raise StatisticsError, "item #{i}: NaN is not allowed" if f.nan?
      raise StatisticsError, "item #{i}: infinity is not allowed" if f.infinite?

      values << f
    end
    raise StatisticsError, "no data points: at least one value is required" if values.empty?

    values
  end

  def neumaier_sum(values)
    sum = 0.0
    c = 0.0
    values.each do |x|
      t = sum + x
      c += sum.abs >= x.abs ? (sum - t) + x : (x - t) + sum
      sum = t
    end
    sum + c
  end

  def mean_and_ss(values)
    n = values.size
    m = neumaier_sum(values) / n
    d = values.map { |x| x - m }
    ss = neumaier_sum(d.map { |v| v * v }) - (neumaier_sum(d)**2) / n
    [m, [ss, 0.0].max]
  end

  def need_two(n)
    raise StatisticsError, "sample statistics need at least 2 data points, got #{n}" if n < 2
  end

  private_class_method :to_floats, :neumaier_sum, :mean_and_ss, :need_two
end
