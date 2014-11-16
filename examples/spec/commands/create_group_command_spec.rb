require 'tiny_spec_helper'
require 'create_group_command'

RSpec.describe CreateGroupCommand do
  let(:notifier) { double("notifier") }
  let(:command) { CreateGroupCommand.new(group: group, notifier: notifier, user: user) }
  let(:group) { double("group") }
  let(:user) { double("user") }

  describe "operations" do
    before do
      allow(command).to receive(:transaction).and_yield
      allow(command).to receive_message_chain("on_success.call") { true }
    end

    describe "save group" do
      before do
        allow(command).to receive(:send_notifications!)
      end

      it "saves" do
        expect(group).to receive(:save!)
        command.call
      end
    end

    describe "send notification" do
      before do
        allow(command).to receive(:save_group!)
      end

      context "when user receives email" do
        before do
          allow(command).to receive(:send_user_email?).and_return(true)
        end

        it "sends" do
          # NB: You'll want to set `raise_delivery_errors` for mail to work
          # transactionally.
          expect(notifier).to receive(:deliver)
          command.call
        end
      end

      context "when user does not receive email" do
        before do
          allow(command).to receive(:send_user_email?).and_return(false)
        end

        it "does not send" do
          expect(notifier).not_to receive(:deliver)
          command.call
        end
      end
    end
  end


  describe "guards" do
    describe "#send_user_email?" do
      context "when user does not receive email" do
        let(:user) { double("user", receives_email?: false) }

        it "returns false" do
          expect(command.send(:send_user_email?)).to eq(false)
        end
      end

      context "when user receives email" do
        let(:user) { double("user", receives_email?: true) }

        it "returns true" do
          expect(command.send(:send_user_email?)).to eq(true)
        end
      end
    end
  end
end
