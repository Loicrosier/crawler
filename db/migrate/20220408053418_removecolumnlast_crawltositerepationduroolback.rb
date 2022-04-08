class RemovecolumnlastCrawltositerepationduroolback < ActiveRecord::Migration[6.1]
  def change
    remove_column :sites, :last_crawl
    add_column :sites, :last_crawl, :time, default: nil
  end
end
