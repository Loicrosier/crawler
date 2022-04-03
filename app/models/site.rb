class Site < ApplicationRecord
  has_many :pages, dependent: :destroy
end
