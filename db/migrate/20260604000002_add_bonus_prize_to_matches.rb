class AddBonusPrizeToMatches < ActiveRecord::Migration[8.1]
  def change
    add_column :matches, :bonus_prize, :decimal, precision: 10, scale: 2, default: 0, null: false
  end
end
