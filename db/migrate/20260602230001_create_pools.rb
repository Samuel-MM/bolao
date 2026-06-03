class CreatePools < ActiveRecord::Migration[8.1]
  def change
    create_table :pools do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :min_bet_amount, precision: 10, scale: 2, null: false, default: 0
      t.string :status, null: false, default: "open"
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.string :invite_token, null: false

      t.timestamps
    end

    add_index :pools, :invite_token, unique: true
  end
end
