class CreateSitemaps < ActiveRecord::Migration[6.1]
  def change
    create_table :sitemaps do |t|
      t.references :site, null: false, foreign_key: true
      t.string :text

      t.timestamps
    end
  end
end
