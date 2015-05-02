require 'spec_helper'
require 'skywalker/acceptable'

module Skywalker
  RSpec.describe Acceptable do
    let(:klass) { Class.new { include Acceptable } }

    describe "instantiation" do
      it "freezes the arguments given to it" do
        instance = klass.new(a_symbol: :my_symbol)
        expect(instance._args).to be_frozen
      end

      it "accepts a variable list of arguments" do
        expect { klass.new(a_symbol: :my_symbol, a_string: "my string") }.not_to raise_error
      end

      it "sets a reader for each argument" do
        instance = klass.new(a_symbol: :my_symbol)
        expect(instance).to respond_to(:a_symbol)
      end

      it "sets a writer for each argument" do
        instance = klass.new(a_symbol: :my_symbol)
        expect(instance).to respond_to(:a_symbol=)
      end

      it "sets the instance variable to the passed value" do
        instance = klass.new(a_symbol: :my_symbol)
        expect(instance.a_symbol).to eq(:my_symbol)
      end

      it "raises an error if an argument in its required_args is not present" do
        allow_any_instance_of(klass).to receive(:required_args).and_return([:required_arg])
        expect { klass.new }.to raise_error
      end

      it "does not raise an error if an argument in its required_args is present" do
        allow_any_instance_of(klass).to receive(:required_args).and_return([:required_arg])
        expect { klass.new(required_arg: :blah) }.not_to raise_error
      end
    end
  end
end

