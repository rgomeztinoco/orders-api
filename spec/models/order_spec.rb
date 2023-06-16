require "rails_helper"

RSpec.describe Order, type: :model do
  describe "validations" do
    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount).is_greater_than(0) }
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(Order::STATUSES) }
    it { should validate_presence_of(:payment_status) }
    it {
      should validate_inclusion_of(:payment_status).in_array(Order::PAYMENT_STATUSES)
    }
  end

  describe "associations" do
    it { should belong_to(:user) }
  end
end
