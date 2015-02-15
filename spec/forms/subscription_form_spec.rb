require 'rails_helper'

describe SubscriptionForm do
  describe "amount" do
    it "is valid if it is an integer" do
      form = SubscriptionForm.new
      form.stub amount: '3.50'
      form.should be_valid
    end

    it "is invalid if it has non-numeric characters" do
      form = SubscriptionForm.new
      form.stub amount: '$30 dollars'
      form.should be_invalid
    end

    it "is invalid if amount is below 0" do
      form = SubscriptionForm.new
      form.stub amount: '-3'
      form.should be_invalid
    end

    context "when preset_amount == 'custom'" do
      it "returns custom_amount" do
        form = SubscriptionForm.new('preset_amount' => 'custom', 'custom_amount' => '23')
        expect(form.amount).to eq ('23')
      end
    end

    context "when preset_amount is blank" do
      it "returns custom_amount" do
        form = SubscriptionForm.new('preset_amount' => '', 'custom_amount' => '23')
        expect(form.amount).to eq ('23')
      end
    end

    context "when both preset_amount and custom_amount have numeric values" do
      it "returns preset_amount" do
        form = SubscriptionForm.new('preset_amount' => '52', 'custom_amount' => '23')
        expect(form.amount).to eq ('52')
      end
    end
  end

  describe "#amount_with_cents" do
    it "always returns amount with two decimal places" do
      form = SubscriptionForm.new
      form.stub amount: '2.5'
      expect(form.amount_with_cents).to eq ('2.50')
      form.stub amount: '12'
      expect(form.amount_with_cents).to eq ('12.00')
    end
  end
end
