class Addcolummetadescriontopages < ActiveRecord::Migration[6.1]
  def change
    add_column :pages, :meta_description, :string
  end
end
