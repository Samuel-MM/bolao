class CreatePoolMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :pool_memberships do |t|
      t.references :pool, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.datetime :approved_at

      t.timestamps
    end

    add_index :pool_memberships, [:pool_id, :user_id], unique: true
  end
end
