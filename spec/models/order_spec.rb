require "rails_helper"

RSpec.describe Order do
  describe "validations" do
    subject(:order) { build(:order) }

    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_numericality_of(:amount).is_greater_than(0) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:payment_status) }

    it "validates inclusion of status" do
      expect(order)
        .to validate_inclusion_of(:status).in_array(Order::STATUSES.values)
    end

    it "validates inclusion of payment_status" do
      expect(order)
        .to(validate_inclusion_of(:payment_status)
              .in_array(Order::PAYMENT_STATUSES.values))
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end
end
