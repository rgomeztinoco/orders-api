class Order < ApplicationRecord
  # Associations
  belongs_to :user

  # Constants
  PAYMENT_STATUSES = {
    paid: "pagada",
    unpaid: "no pagada",
    pending: "pendiente de pago"
  }.freeze
  STATUSES = {
    received: "recibida",
    preparing: "en preparación",
    delivering: "en reparto",
    delivered: "entregada"
  }.freeze

  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: STATUSES.values }
  validates :payment_status, presence: true,
                             inclusion: { in: PAYMENT_STATUSES.values }

  # Methods
  def paid?
    payment_status == PAYMENT_STATUSES[:paid]
  end

  def payment_status=(value)
    super(value)
    self.paid_at = Time.zone.now if paid?
  end

  def delivered?
    status == STATUSES[:delivered]
  end

  def status=(value)
    super(value)
    self.delivered_at = Time.zone.now if delivered?
  end
end
