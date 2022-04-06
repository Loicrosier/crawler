class Site < ApplicationRecord
  has_many :pages, dependent: :destroy
  has_many :sitemaps, dependent: :destroy
end
