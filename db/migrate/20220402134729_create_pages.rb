class CreatePages < ActiveRecord::Migration[6.1]
  def change
    create_table :pages do |t|
      t.string :url
      t.text :content
      t.references :site, null: false, foreign_key: true

      t.timestamps
    end
  end
end
