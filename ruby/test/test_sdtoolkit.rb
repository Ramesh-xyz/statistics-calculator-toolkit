# frozen_string_literal: true

require "minitest/autorun"
require "bigdecimal"
require_relative "../lib/sdtoolkit"

class TestSDToolkit < Minitest::Test
  CLASSIC = [2, 4, 4, 4, 5, 5, 7, 9].freeze
  OFFSET = [1e9 + 4, 1e9 + 7, 1e9 + 13, 1e9 + 16].freeze

  def test_classic
    assert_equal 5.0, SDToolkit.mean(CLASSIC)
    assert_equal 32.0, SDToolkit.sum_of_squares(CLASSIC)
    assert_equal 4.0, SDToolkit.population_variance(CLASSIC)
    assert_equal 2.0, SDToolkit.population_stdev(CLASSIC)
    assert_in_delta 32.0 / 7, SDToolkit.sample_variance(CLASSIC), 1e-15
    assert_in_delta 2.138089935299395, SDToolkit.sample_stdev(CLASSIC), 1e-15
    assert_in_delta 42.7617987059879, SDToolkit.relative_std_dev(CLASSIC), 1e-12
    assert_equal 40.0, SDToolkit.relative_std_dev(CLASSIC, population: true)
    assert_in_delta 2.138089935299395 / 5, SDToolkit.coefficient_of_variation(CLASSIC), 1e-15
  end

  def test_large_offset_exact
    assert_equal 90.0, SDToolkit.sum_of_squares(OFFSET)
    assert_equal 30.0, SDToolkit.sample_variance(OFFSET)
  end

  def test_negative_mean_uses_absolute_value
    assert_equal SDToolkit.relative_std_dev([2, 4, 6], population: true),
                 SDToolkit.relative_std_dev([-2, -4, -6], population: true)
  end

  def test_single_value
    assert_equal 0.0, SDToolkit.population_variance([7])
    assert_equal 0.0, SDToolkit.population_stdev([7])
    %i[sample_variance sample_stdev relative_std_dev coefficient_of_variation describe].each do |m|
      err = assert_raises(SDToolkit::StatisticsError) { SDToolkit.public_send(m, [7]) }
      assert_match(/at least 2/, err.message)
    end
  end

  def test_zero_mean
    err = assert_raises(SDToolkit::StatisticsError) { SDToolkit.relative_std_dev([-1, 1]) }
    assert_match(/mean is zero/, err.message)
    assert_raises(SDToolkit::StatisticsError) { SDToolkit.coefficient_of_variation([-2, 0, 2], population: true) }
    assert_nil SDToolkit.describe([-1, 1]).rsd_percent
  end

  def test_describe
    s = SDToolkit.describe(CLASSIC, population: true)
    assert_equal [8, 5.0, 4.0, 2.0, 40.0], [s.n, s.mean, s.variance, s.stdev, s.rsd_percent]
    assert_equal [2.0, 9.0, 7.0, 32.0], [s.minimum, s.maximum, s.range, s.sum_of_squares]
    assert s.population
    assert s.frozen?
    refute SDToolkit.describe([1, 2]).population
  end

  def test_other_numeric_types
    assert_equal 2.0, SDToolkit.mean([Rational(3, 2), BigDecimal("2.5")])
    assert_equal 2.0, SDToolkit.mean((1..3).each)
  end

  def test_error_is_argument_error
    assert SDToolkit::StatisticsError < ArgumentError
  end

  def test_empty
    %i[mean sum_of_squares population_variance population_stdev].each do |m|
      err = assert_raises(SDToolkit::StatisticsError) { SDToolkit.public_send(m, []) }
      assert_match(/no data points/, err.message)
    end
  end

  def test_rejected_items
    {
      [1, Float::NAN] => /item 1: NaN/,
      [1, Float::INFINITY] => /item 1: infinity/,
      [1, -Float::INFINITY] => /infinity/,
      [1, nil, 3] => /item 1: nil/,
      [1, true] => /booleans/,
      [1, false] => /booleans/,
      [1, "2"] => /strings are not accepted/,
      [1, Complex(1, 1)] => /not a real number/,
      [1, BigDecimal("NaN")] => /NaN/,
      [1, 10**400] => /infinity/
    }.each do |data, pattern|
      err = assert_raises(SDToolkit::StatisticsError, data.inspect) { SDToolkit.mean(data) }
      assert_match pattern, err.message
    end
  end

  def test_string_input
    err = assert_raises(SDToolkit::StatisticsError) { SDToolkit.mean("123") }
    assert_match(/got a string/, err.message)
  end
end
