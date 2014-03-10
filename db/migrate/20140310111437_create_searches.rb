class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.text :term

      t.timestamps
    end
  end
end
