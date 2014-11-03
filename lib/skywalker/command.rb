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
    def initialize(on_success: nil, on_failure: nil)
      self.on_success = on_success
      self.on_failure = on_failure
    end


    attr_accessor :on_success,
                  :on_failure,
                  :error


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
      on_success.call(self)
    end


    ################################################################################
    # Set the error so we can get it with `command.error`, and trigger error.
    ################################################################################
    private def confirm_failure(error)
      self.error = error
      on_failure.call(self)
    end
  end
end
