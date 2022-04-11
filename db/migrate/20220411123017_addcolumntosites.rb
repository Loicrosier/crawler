class Addcolumntosites < ActiveRecord::Migration[6.1]
  def change
    add_column :sites, :page_count_crawl, :integer
    add_column :sites, :page_count_sitemap, :integer
  end
end
