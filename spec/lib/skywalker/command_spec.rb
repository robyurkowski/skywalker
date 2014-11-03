require 'spec_helper'
require 'skywalker/command'

module Skywalker
  RSpec.describe Command do
    describe "convenience" do
      it "provides a class call method that instantiates and calls" do
        arg = 'blah'

        expect(Command).to receive_message_chain('new.call')
        Command.call(arg)
      end
    end


    describe "instantiation" do
      it "accepts an on_success callback" do
        expect { Command.new(on_success: ->{ nil }) }.not_to raise_error
      end

      it "accepts an on_failure callback" do
        expect { Command.new(on_failure: ->{ nil }) }.not_to raise_error
      end
    end


    describe "validity control" do
      let(:command) { Command.new }

      it "executes in a transaction" do
        expect(command).to receive(:transaction)
        command.call
      end
    end


    describe "execution" do
      before do
        allow(command).to receive(:transaction).and_yield
      end


      describe "success handling" do
        let(:on_success) { double("on_success callback") }
        let(:command) { Command.new(on_success: on_success) }

        before do
          allow(command).to receive(:execute!).and_return(true)
        end

        it "triggers the confirm_success method" do
          expect(command).to receive(:confirm_success)
          command.call
        end

        it "calls the on_success callback with itself" do
          expect(on_success).to receive(:call).with(command)
          command.call
        end
      end


      describe "failure handling" do
        let(:on_failure) { double("on_failure callback") }
        let(:command) { Command.new(on_failure: on_failure) }

        before do
          allow(command).to receive(:execute!).and_raise(ScriptError)
        end

        it "triggers the confirm_failure method" do
          expect(command).to receive(:confirm_failure)
          command.call
        end

        it "sets the error on the command" do
          allow(on_failure).to receive(:call)
          expect(command).to receive(:error=)
          command.call
        end

        it "calls the on_failure callback with itself" do
          allow(command).to receive(:error=)
          expect(on_failure).to receive(:call).with(command)
          command.call
        end
      end
    end
  end
end
