require "active_support"
require "active_support/core_ext"
require "active_record_seek/version"
require "active_record_seek/operator"
require "active_record_seek/extension/association"
require "active_record_seek/extension/paginate"
require "active_record_seek/extension/seek"
require "active_record_seek/extension/seek_or"
require "active_record_seek/extension/search"
require "active_record_seek/extension/builders"

# active_record hook
ActiveSupport.on_load(:active_record) do
  extend ActiveRecordSeek::Extension
  # build arel operators
  Arel::Predications.instance_methods.each do |operator|
    ActiveRecordSeek::Operator.add(
      operator: operator,
      matcher: /_#{operator}\z/,
      case_insensitive: false,
    )
    # add insensitive operators
    insensitive_eq_matcher = /(\A|_)eq(\z|_)/
    if operator =~ insensitive_eq_matcher
      insensitive_operator = operator.to_s.gsub(insensitive_eq_matcher, '\1ieq\2').to_sym
      ActiveRecordSeek::Operator.add(
        operator: insensitive_operator,
        matcher: /_#{insensitive_operator}\z/,
        case_insensitive: true,
      )
    end
  end
end
