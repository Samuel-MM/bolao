class CreateMatches < ActiveRecord::Migration[8.1]
  def change
    create_table :matches do |t|
      t.references :pool, null: false, foreign_key: true
      t.string :home_team, null: false
      t.string :away_team, null: false
      t.datetime :kickoff_at, null: false
      t.string :status, null: false, default: "scheduled"
      t.integer :home_score
      t.integer :away_score
      t.integer :api_football_id

      t.timestamps
    end

    add_index :matches, :api_football_id
  end
end
