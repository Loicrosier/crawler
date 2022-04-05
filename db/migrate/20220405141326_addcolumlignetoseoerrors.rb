class Addcolumlignetoseoerrors < ActiveRecord::Migration[6.1]
  def change
    add_column :seoerrors, :ligne, :integer
  end
end
