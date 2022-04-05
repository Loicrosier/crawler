class CreateSeoerrors < ActiveRecord::Migration[6.1]
  def change
    create_table :seoerrors do |t|
      t.references :page, null: false, foreign_key: true
      t.string :text

      t.timestamps
    end
  end
end
