require 'active_record'
require 'skywalker/acceptable'

module Skywalker
  class Command
    include Acceptable

    ################################################################################
    # Class interface
    ################################################################################

    #
    # Provides a convenient way to call a command without having to instantiate
    # and call.
    #
    # @since 1.0.0
    #
    def self.call(*args)
      new(*args).call
    end


    attr_accessor :on_success,
                  :on_failure,
                  :error


    #
    # Call: runs the transaction and all operations.
    #
    # @since 1.0.0
    #
    def call
      transaction do
        execute!

        confirm_success
      end

    rescue Exception => error
      confirm_failure error
    end


    #
    # Procedural execution method. This should be implemented inside subclasses
    # to add operations.
    #
    # @since 1.0.0
    #
    protected def execute!
    end


    ################################################################################
    # Private interface
    ################################################################################


    #
    # Wraps the given block in transactional logic.
    #
    # @since 1.0.0
    #
    private def transaction(&block)
      ::ActiveRecord::Base.transaction(&block)
    end

    #
    # Triggers the given callback on success
    #
    # @since 1.0.0
    #
    private def confirm_success
      run_success_callbacks
    end


    #
    # Runs success callback if given. Override to specify additional callbacks
    # or to add branching logic here.
    #
    # @since 1.1.0
    #
    private def run_success_callbacks
      on_success.call(self) unless on_success.nil?
    end


    #
    # Triggered on failure of transaction. Sets `#error` so the exception can
    # be retrieved, and triggers the error callbacks.
    #
    # @since 1.0.0
    #
    private def confirm_failure(error)
      self.error = error
      run_failure_callbacks
    end


    #
    # Runs failure callback if given. Override to specify additional callbacks
    # or to add branching logic here.
    #
    # @since 1.1.0
    #
    private def run_failure_callbacks
      on_failure.call(self) unless on_failure.nil?
    end
  end
end
