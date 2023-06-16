class User < ApplicationRecord
  # Associations
  has_many :orders

  # Validations
  validates :email, presence: true
  validates :name, presence: true
end
