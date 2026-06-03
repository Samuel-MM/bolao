class CreateBets < ActiveRecord::Migration[8.1]
  def change
    create_table :bets do |t|
      t.references :match, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :home_score, null: false
      t.integer :away_score, null: false

      t.timestamps
    end

    add_index :bets, [:match_id, :user_id, :home_score, :away_score],
              unique: true, name: "index_bets_unique_scoreline"
  end
end
