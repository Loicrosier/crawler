class CreateTitles < ActiveRecord::Migration[6.1]
  def change
    create_table :titles do |t|
      t.string :h1
      t.string :h2
      t.string :h3
      t.string :h4
      t.string :h5
      t.string :h6

      t.timestamps
    end
  end
end
