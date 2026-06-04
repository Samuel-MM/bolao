class AddCrestsToMatches < ActiveRecord::Migration[8.1]
  def change
    add_column :matches, :home_crest, :string
    add_column :matches, :away_crest, :string
  end
end
