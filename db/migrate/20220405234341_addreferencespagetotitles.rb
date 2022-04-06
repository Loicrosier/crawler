class Addreferencespagetotitles < ActiveRecord::Migration[6.1]
  def change
    add_reference :titles, :page, foreign_key: true
  end
end
