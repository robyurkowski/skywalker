module Skywalker
  module Acceptable

    #
    # Creates an `_args` accessor on inclusion.
    #
    # @since 2.0.0
    #
    def self.included(klass)
      klass.send(:attr_accessor, :_args)
    end


    #
    # Instantiates an object, setting all kwargs as accessors, and yields self
    # to any block given.
    #
    # @since 2.0.0
    #
    def initialize(**args)
      self._args = args
      self._args.freeze

      validate_arguments!
      parse_arguments

      yield self if block_given?
    end


    #
    # Ensures required keys are present.
    #
    # @since 2.0.0
    #
    private def validate_arguments!
      missing_args = required_args.map(&:to_s) - _args.keys.map(&:to_s)

      raise ArgumentError, "#{missing_args.join(", ")} required but not given" \
        if missing_args.any?
    end


    #
    # Specifies required arguments to the object. Should be an array of objects
    # that are coercible to keyword names via `to_s`.
    #
    # @since 2.0.0
    #
    private def required_args
      []
    end


    #
    # Creates an attr_accessor for each passed kwarg and assigns the argument.
    #
    # @since 2.0.0
    #
    private def parse_arguments
      _args.each_pair do |reader_method, value|
        writer_method = "#{reader_method}="

        singleton_class.class_eval do
          send(:attr_reader, reader_method) unless respond_to?(reader_method)
          send(:attr_writer, reader_method) unless respond_to?(writer_method)
        end

        self.send(writer_method, value)
      end
    end
  end
end
