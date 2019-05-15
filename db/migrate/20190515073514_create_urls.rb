class CreateUrls < ActiveRecord::Migration[5.2]
  def change
    create_table :urls do |t|
      t.string :origin_url
      t.string :slug
      t.date :expiration_date
      t.integer :hits, default: 0

      t.timestamps
    end
  end
end
