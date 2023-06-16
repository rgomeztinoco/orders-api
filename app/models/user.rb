class User < ApplicationRecord
  # Associations
  has_many :orders, dependent: :nullify

  # Validations
  validates :email, presence: true
  validates :name, presence: true
end
