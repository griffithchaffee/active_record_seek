module ActiveRecordSeek
  class Middleware

    attr_accessor(*%w[ name middleware_block ])

    def initialize(name:, &middleware_block)
      raise(ArgumentError, "#{self.class} expects a block") if !middleware_block
      self.name = name.to_s
      self.middleware_block = middleware_block
      self.class.middleware.push(self)
    end

    def call(*params, &block)
      middleware_block.call(*params, &block)
    end

    class << self
      def middleware
        @middleware ||= []
      end
    end

  end
end
