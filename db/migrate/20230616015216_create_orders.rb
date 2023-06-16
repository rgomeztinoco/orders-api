class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.float :amount
      t.string :payment_status
      t.string :status
      t.time :paid_at
      t.time :delivered_at
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
