module ActiveRecordSeekTest

  class BaseTest < Minitest::Test
    make_my_diffs_pretty!
  end

  class QueryTest < BaseTest
    def setup
      AdapterDatabase.instance.drop_data!
    end

    def assert_equal_records(expected_records, actual_records, *params)
      assert_equal(
        expected_records.to_a,
        actual_records.to_a,
        *params
      )
    end

    def assert_equal_sql(multiline_expected_sql, actual_sql, *params)
      expected_sql = multiline_expected_sql.lines.map(&:strip).join
      # convert from " to ` for MySQL
      if AdapterDatabase.instance.adapter_namespace == "mysql"
        expected_sql.gsub!('"', "`")
      end
      assert_equal(
        expected_sql,
        actual_sql,
        *params
      )
    end
  end

end
