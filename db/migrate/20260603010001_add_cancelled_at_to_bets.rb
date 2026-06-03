class AddCancelledAtToBets < ActiveRecord::Migration[8.1]
  def change
    add_column :bets, :cancelled_at, :datetime

    remove_index :bets, name: "index_bets_unique_scoreline"

    add_index :bets, [:match_id, :user_id, :home_score, :away_score],
              unique: true,
              where: "cancelled_at IS NULL",
              name: "index_bets_unique_scoreline_active"
  end
end
