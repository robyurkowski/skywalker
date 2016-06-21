require 'spec_helper'
require 'skywalker/transactional'

module Skywalker
  RSpec.describe Transactional do
    let(:klass) { Class.new { include Transactional } }

    describe "#transaction" do
      let(:block) { Proc.new { "hey" } }
      let(:instance) { klass.new }
      let(:tx_method) { double("tx_method") }

      context "when ActiveRecord is present" do
        before do
          allow(instance).to receive(:active_record_defined?).and_return true
          allow(instance).to receive(:active_record_transaction_method).and_return tx_method
        end

        it "calls the transaction method with the block" do
          allow(tx_method).to receive(:call) do |&blk|
            blk.call(&block)
          end

          expect(instance.send(:transaction, &block)).to eq "hey"
        end
      end

      context "when ActiveRecord is not present" do
        before do
          allow(instance).to receive(:active_record_defined?).and_return false
        end

        it "calls the block" do
          expect(instance.send(:transaction, &block)).to eq "hey"
        end
      end
    end

    describe "validity control" do
      let(:instance) { klass.new }

      it "executes in a transaction" do
        expect(instance).to receive(:transaction)
        instance.call
      end
    end

    describe "execution" do
      before do
        allow(instance).to receive(:transaction).and_yield
      end


      describe "success handling" do
        let(:on_success) { double("on_success callback") }
        let(:instance) { klass.new(on_success: on_success) }

        before do
          allow(instance).to receive(:execute!).and_return(true)
        end

        it "triggers the confirm_success method" do
          expect(instance).to receive(:confirm_success)
          instance.call
        end

        it "runs the success callbacks" do
          expect(instance).to receive(:run_success_callbacks)
          instance.call
        end

        describe "on_success" do
          context "when on_success is not nil" do
            it "calls the on_success callback with itself" do
              expect(on_success).to receive(:call).with(instance)
              instance.call
            end

            context "when on_success is not callable" do
              let(:on_failure) { double("on_failure") }
              let(:instance) { klass.new(on_success: "a string", on_failure: on_failure) }

              it "confirms failure if the on_success callback fails" do
                expect(on_failure).to receive(:call).with(instance)
                instance.call
              end
            end
          end

          context "when on_success is nil" do
            let(:nil_callback) { double("fakenil", nil?: true) }
            let(:instance) { klass.new(on_success: nil_callback) }

            it "does not call on_success" do
              expect(nil_callback).not_to receive(:call)
              instance.call
            end
          end
        end
      end


      describe "failure handling" do
        let(:on_failure) { double("on_failure callback") }
        let(:instance) { klass.new(on_failure: on_failure) }

        before do
          allow(instance).to receive(:execute!).and_raise(ScriptError)
        end

        it "triggers the confirm_failure method" do
          expect(instance).to receive(:confirm_failure)
          instance.call
        end

        it "sets the error on the instance" do
          allow(on_failure).to receive(:call)
          expect(instance).to receive(:error=)
          instance.call
        end

        it "runs the failure callbacks" do
          allow(instance).to receive(:error=)
          expect(instance).to receive(:run_failure_callbacks)
          instance.call
        end

        describe "on_failure" do
          before do
            allow(instance).to receive(:error=)
          end

          context "when on_failure is not nil" do
            it "calls the on_failure callback with itself" do
              expect(on_failure).to receive(:call).with(instance)
              instance.call
            end

            context "when on_failure is not callable" do
              let(:instance) { klass.new(on_failure: "a string") }

              it "raises an error" do
                expect { instance.call }.to raise_error NoMethodError
              end
            end
          end

          context "when on_failure is nil" do
            let(:nil_callback) { double("fakenil", nil?: true) }
            let(:instance) { klass.new(on_failure: nil_callback) }

            it "does not call on_failure" do
              expect(nil_callback).not_to receive(:call)
              instance.call
            end
          end
        end
      end
    end

  end
end

