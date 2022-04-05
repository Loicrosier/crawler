Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get 'site/new', to: 'sites#new'
  post 'site/create', to: 'sites#create'
  get 'site/:id', to: 'sites#show', as: 'site'
  get 'sites', to: 'sites#index'
  get 'crawl/:id', to: 'sites#crawl', as: 'crawl'

  get 'page/:id', to: 'pages#show', as: 'page'

end