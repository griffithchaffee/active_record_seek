module ActiveRecordSeekTest

  class BaseTest < Minitest::Test
    make_my_diffs_pretty!
  end

  class QueryTest < BaseTest
    def setup
      MemoryDatabase.instance.reset!
    end

    def assert_equal_groups(expected_groups, actual_groups)
      assert_equal(
        expected_groups.map(&:id),
        actual_groups.map(&:id)
      )
    end

    def assert_equal_sql(expected_sql, actual_sql)
      assert_equal(
        expected_sql.lines.map(&:strip).join,
        actual_sql,
      )
    end
  end

end
