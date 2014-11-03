require 'spec_helper'
require 'skywalker/command'

module Skywalker
  RSpec.describe Command do
    describe "convenience" do
      it "provides a class call method that instantiates and calls" do
        expect(Command).to receive_message_chain('new.call')
        Command.call
      end
    end


    describe "instantiation" do
      it "accepts a variable list of arguments" do
        expect { Command.new(a_symbol: :my_symbol, a_string: "my string") }.not_to raise_error
      end

      it "sets an instance variable for each argument" do
        command = Command.new(a_symbol: :my_symbol)
        expect(command.a_symbol).to eq(:my_symbol)
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

        it "runs the success callbacks" do
          expect(command).to receive(:run_success_callbacks)
          command.call
        end

        describe "on_success" do
          context "when on_success is defined" do
            it "calls the on_success callback with itself" do
              expect(on_success).to receive(:call).with(command)
              command.call
            end
          end

          context "when on_success is not defined" do
            let(:command) { Command.new }

            it "does not call on_success" do
              expect(command).not_to receive(:on_success)
            end
          end
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

        it "runs the failure callbacks" do
          allow(command).to receive(:error=)
          expect(command).to receive(:run_failure_callbacks)
          command.call
        end

        describe "on_failure" do
          before do
            allow(command).to receive(:error=)
          end

          context "when on_failure is defined" do
            it "calls the on_failure callback with itself" do
              expect(on_failure).to receive(:call).with(command)
              command.call
            end
          end

          context "when on_failure is not defined" do
            let(:command) { Command.new }

            it "does not call on_failure" do
              expect(command).not_to receive(:on_failure)
            end
          end
        end
      end
    end
  end
end
