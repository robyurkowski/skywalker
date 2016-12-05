require 'skywalker/acceptable'

module Skywalker
  module Transactional

    #
    # Requires Acceptable and add accessors for callbacks.
    #
    # @since 2.2.0
    #
    def self.included(klass)
      klass.include Acceptable
      klass.send(:attr_accessor, :on_success, :on_failure, :error)
    end


    #
    # Runs the transaction and all operations.
    #
    # @since 2.2.0
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
    # @since 2.2.0
    #
    protected def execute!
    end


    ################################################################################
    # Private interface
    ################################################################################


    #
    # Wraps the given block in transactional logic.
    #
    # @since 2.2.0
    #
    private def transaction(&block)
      if active_record_defined?
        active_record_transaction_method.call(&block)
      else
        block.call
      end
    end


    #
    # Allows us to artificially declare whether AR is loaded for specs.
    #
    # @since 2.2.0
    #
    private def active_record_defined?
      defined?(ActiveRecord)
    end

    #
    # Allows us to artificially choose which method to use as the AR
    # transaction method.
    #
    # @since 2.2.0
    #
    private def active_record_transaction_method
      ::ActiveRecord::Base.method(:transaction)
    end


    #
    # Triggers the given callback on success
    #
    # @since 2.2.0
    #
    private def confirm_success
      run_success_callbacks
    end


    #
    # Runs success callback if given. Override to specify additional callbacks
    # or to add branching logic here.
    #
    # @since 2.2.0
    #
    private def run_success_callbacks
      on_success.call(self) unless on_success.nil?
    end


    #
    # Triggered on failure of transaction. Sets `#error` so the exception can
    # be retrieved, and triggers the error callbacks.
    #
    # @since 2.2.0
    #
    private def confirm_failure(error)
      self.error = error
      run_failure_callbacks
    end


    #
    # Runs failure callback if given. Override to specify additional callbacks
    # or to add branching logic here.
    #
    # @since 2.2.0
    #
    private def run_failure_callbacks
      if on_failure
        on_failure.call(self)
      else
        raise error
      end
    end

  end
end
