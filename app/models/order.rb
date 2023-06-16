class Order < ApplicationRecord
  # Associations
  belongs_to :user

  # Constants
  PAYMENT_STATUSES = ["pagada", "no pagada", "pendiente de pago"].freeze
  STATUSES = ["recibida", "en preparación", "en reparto", "entregada"].freeze

  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :payment_status, presence: true,
                             inclusion: { in: PAYMENT_STATUSES }

  # Methods
  def paid?
    payment_status == "pagada"
  end

  def payment_status=(value)
    super(value)
    self.paid_at = Time.zone.now if paid?
  end

  def delivered?
    status == "entregada"
  end

  def status=(value)
    super(value)
    self.delivered_at = Time.zone.now if delivered?
  end
end
