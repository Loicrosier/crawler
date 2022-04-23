class Site < ApplicationRecord
  has_many :pages, dependent: :destroy
  # has_many :hxerrors, through: :pages
  validates :name, presence: true, uniqueness: true
  validates :url, presence: true, uniqueness: true
end
