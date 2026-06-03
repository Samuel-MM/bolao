class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :bet, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.text :pix_code
      t.text :qr_code_svg
      t.string :proof_url
      t.datetime :paid_at
      t.datetime :approved_at
      t.datetime :refund_requested_at
      t.datetime :refund_processed_at

      t.timestamps
    end
  end
end
