module ActiveRecordSeekTest

  class BaseTest < Minitest::Test
    make_my_diffs_pretty!
  end

  class QueryTest < BaseTest
    def setup
      MemoryDatabase.instance.reset!
    end

    def assert_equal_groups(expected_groups, actual_groups, *params)
      assert_equal(
        expected_groups.map(&:id),
        actual_groups.map(&:id),
        *params
      )
    end

    def assert_equal_sql(expected_sql, actual_sql, *params)
      assert_equal(
        expected_sql.lines.map(&:strip).join,
        actual_sql,
        *params
      )
    end
  end

end
