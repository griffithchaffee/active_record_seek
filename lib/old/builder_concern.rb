module ActiveRecordSeek
  module BuilderConcern
    extend ActiveSupport::Concern

    class_methods do
      def build_seek_scopes
        # used to define seek scopes
      end
    end
  end
end
