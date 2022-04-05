class Addcolumncanonicaltopages < ActiveRecord::Migration[6.1]
  def change
    add_column :pages, :canonical, :boolean, default: false
  end
end
