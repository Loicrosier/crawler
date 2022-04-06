class Page < ApplicationRecord
  belongs_to :site
  has_many :hxerrors, dependent: :destroy
  has_many :seoerrors, dependent: :destroy
  has_many :titles, dependent: :destroy
end
