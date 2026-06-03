class AddRejectionReasonToPayments < ActiveRecord::Migration[8.1]
  def change
    add_column :payments, :rejection_reason, :text
  end
end
