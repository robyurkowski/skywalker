module Skywalker
  module Callable

    #
    # Extend instead of include because we'd prefer to keep a uniform interface
    # among Skywalker extensions, and we have in the past had additional
    # instance methods defined herein.
    #
    # @since 2.2.0
    #
    def self.included(klass)
      klass.extend ClassMethods
    end


    module ClassMethods

      #
      # Provides a convenient way to call a command without having to instantiate
      # and call.
      #
      # @since 2.2.0
      #
      def call(*args)
        new(*args).call
      end
    end
  end
end

