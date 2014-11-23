require 'active_record'

module Skywalker
  class Command
    ################################################################################
    # Class interface
    ################################################################################
    def self.call(*args)
      new(*args).call
    end


    ################################################################################
    # Instantiates command, setting all arguments.
    ################################################################################
    def initialize(**args)
      self.args = args
      self.args.freeze

      parse_arguments
      validate_arguments!

    end


    attr_accessor :on_success,
                  :on_failure,
                  :error,
                  :args


    ################################################################################
    # Ensure required keys are present.
    ################################################################################
    private def validate_arguments!
      missing_args = required_args.map(&:to_s) - args.keys.map(&:to_s)

      raise ArgumentError, "#{missing_args.join(", ")} required but not given" \
        if missing_args.any?
    end


    ################################################################################
    # Any required keys should go here as either strings or symbols.
    ################################################################################
    private def required_args
      []
    end



    private def parse_arguments
      args.each_pair do |reader_method, value|
        writer_method = "#{reader_method}="

        singleton_class.class_eval do
          send(:attr_reader, reader_method) unless respond_to?(reader_method)
          send(:attr_writer, reader_method) unless respond_to?(writer_method)
        end

        self.send(writer_method, value)
      end
    end


    ################################################################################
    # Call: runs the transaction and all operations.
    ################################################################################
    def call
      transaction do
        execute!

        confirm_success
      end

    rescue Exception => error
      confirm_failure error
    end


    ################################################################################
    # Operations should be defined in this method.
    ################################################################################
    private def execute!
    end

    ################################################################################
    # Override to customize.
    ################################################################################
    private def transaction(&block)
      ::ActiveRecord::Base.transaction(&block)
    end


    ################################################################################
    # Trigger the given callback on success
    ################################################################################
    private def confirm_success
      run_success_callbacks
    end


    private def run_success_callbacks
      on_success.call(self) unless on_success.nil?
    end


    ################################################################################
    # Set the error so we can get it with `command.error`, and trigger error.
    ################################################################################
    private def confirm_failure(error)
      self.error = error
      run_failure_callbacks
    end


    private def run_failure_callbacks
      on_failure.call(self) unless on_failure.nil?
    end
  end
end
