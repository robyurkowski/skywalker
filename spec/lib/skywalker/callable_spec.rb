require 'spec_helper'
require 'skywalker/callable'

module Skywalker
  RSpec.describe Callable do
    let(:klass) { Class.new { include Callable } }

    describe ".call" do
      it "instantiates and calls" do
        expect(klass).to receive_message_chain('new.call')
        klass.call
      end
    end


    describe "#call" do
      it "raises an error because it is not defined" do
        instance = klass.new
        expect { instance.call }.to raise_error NoMethodError
      end
    end
  end
end
