module ActiveRecordSeek
  module Concerns
    module BuildConcern

      extend ActiveSupport::Concern

      def set(params = {})
        params.each { |key, value| send("#{key}=", value) }
        self
      end

      class_methods do
        def build(set_params = {})
          new.set(set_params)
        end
      end

    end
  end
end
