class RemovecolumnlastCrawltosite < ActiveRecord::Migration[6.1]
  def change
    remove_column :sites, :last_crawl
    add_column :sites, :last_crawl, :datetime, default: nil
  end
end
