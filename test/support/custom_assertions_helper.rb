# frozen_string_literal: true

module CustomAssertionsHelper
  UNTRACKED = Object.new

  def assert_no_authorization(&block)
    instance_exec(&block)
    assert_redirected_to(root_url)
  end

  def assert_many_changes(expression_array, message = nil, from_array: UNTRACKED, to_array: UNTRACKED, &block)
    expressions = Array(expression_array)
    from_values = Array(from_array)
    to_values = Array(to_array)

    check_array_size_for(from_values, expressions, :from_array)
    check_array_size_for(to_values, expressions, :to_array)

    before_values = execute_expressions(expressions)
    retval = assert_nothing_raised(&block)
    after_values = execute_expressions(expressions)

    check_assertions_for(before_values, from_values, expressions, :from, message)
    check_refutations_for(before_values, after_values, expressions, to_values, message)
    check_assertions_for(after_values, to_values, expressions, :to, message)

    retval
  end

  def assert_no_many_changes(expression_array, message = nil, &block)
    expressions = Array(expression_array)

    before_values = execute_expressions(expressions)
    retval = assert_nothing_raised(&block)
    after_values = execute_expressions(expressions)

    before_values.zip(after_values).each_with_index do |(before, after), i|
      error = "#{expressions[i].inspect} changed"
      error = "#{message}.\n#{error}" if message

      if before.nil?
        assert_nil(after, error)
      else
        assert_equal(before, after, error)
      end
    end

    retval
  end

  private

  def check_array_size_for(expected_values, expressions, label_case)
    return if expected_values.first == UNTRACKED || expressions.size == expected_values.size

    raise(ArgumentError, "Each expression must have a corresponding value by #{label_case} key")
  end

  def execute_expressions(expressions)
    expressions.map do |exp|
      callable = exp.respond_to?(:call) ? exp : -> { eval(exp.to_s, block.binding) } # rubocop:disable Security/Eval
      callable.call
    end
  end

  def check_assertions_for(changed_values, expected_values, expressions, label_case, message = nil)
    return if expected_values.first == UNTRACKED

    changed_values.zip(expected_values).each_with_index do |(changed, expected), i|
      error = "Expected change #{label_case} #{expected} for the expression: #{expressions[i].inspect}"
      error = "#{message}.\n#{error}" if message
      assert_equal(changed, expected, error)
    end
  end

  def check_refutations_for(before_values, after_values, expressions, to_values, message = nil)
    before_values.zip(after_values).each_with_index do |(before, after), i|
      error = "#{expressions[i].inspect} didn't change"
      error = "#{error}. It was already #{to_values[i]}" if to_values.first != UNTRACKED && before == to_values[i]
      error = "#{message}.\n#{error}" if message
      assert_not_equal(before, after, error)
    end
  end
end
