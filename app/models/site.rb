class Site < ApplicationRecord
  has_many :pages, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :url, presence: true, uniqueness: true
end
