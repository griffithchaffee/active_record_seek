require "test_helper"
require "support/database_models"

class ActiveRecordSeek::SeekTest < ActiveRecordSeek::ModelTest

  def test_order_by
    # assertion proc
    assert_sql = -> (expected_order_sql, actual) do
      actual_sql = actual.to_sql
      expected_sql = %Q[SELECT "groups".* FROM "groups"]
      if expected_order_sql.present?
        expected_sql << " ORDER BY #{expected_order_sql}"
      end
      puts(expected_sql, actual_sql) if expected_sql != actual_sql
      assert_equal(expected_sql, actual_sql, caller.select { |l| l.starts_with?(File.dirname(__FILE__)) }.join("\n"))
    end
    # basic column ordering
    assert_sql.call(%Q["groups"."id" ASC],  Group.order_by(id: :asc))
    assert_sql.call(%Q["groups"."id" DESC], Group.order_by(id: :desc))
    # basic null ordering
    assert_sql.call(%Q["groups"."id" IS NOT NULL], Group.order_by(id: :first))
    assert_sql.call(%Q["groups"."id" IS NULL],     Group.order_by(id: :last))
    # basic combo ordering
    assert_sql.call(%Q["groups"."id" IS NOT NULL, "groups"."id" ASC],  Group.order_by(id: :asc_first))
    assert_sql.call(%Q["groups"."id" IS NULL, "groups"."id" ASC],      Group.order_by(id: :asc_last))
    assert_sql.call(%Q["groups"."id" IS NOT NULL, "groups"."id" DESC], Group.order_by(id: :desc_first))
    assert_sql.call(%Q["groups"."id" IS NULL, "groups"."id" DESC],     Group.order_by(id: :desc_last))
    # reordering
    assert_sql.call(%Q["groups"."id" IS NULL, "groups"."id" DESC],     Group.order(name: :asc).reorder_by(id: :desc_last))
    # complex ordering
    assert_sql.call(
      %Q["groups"."id" IS NOT NULL, "groups"."id" ASC, "groups"."name" IS NULL, "groups"."name" DESC],
      Group.order_by(id: :asc_first, name: :desc_last)
    )
    assert_sql.call(
      %Q["groups"."id" IS NOT NULL, "groups"."id" DESC, "groups"."name" IS NULL, "groups"."name" ASC],
      Group.order_by(id: :asc_first, name: :desc_last).reverse_order!
    )
    # reordering
  end

  def test_order_random
    assert_equal(
      %Q[SELECT "groups".* FROM "groups" ORDER BY RANDOM()],
      Group.order_random.to_sql
    )
  end

end
