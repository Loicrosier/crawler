class Addcolumntosite < ActiveRecord::Migration[6.1]
  def change
    add_column :sites, :last_crawl, :datetime
    add_column :sites, :last_crawl_mode, :string
  end
end
