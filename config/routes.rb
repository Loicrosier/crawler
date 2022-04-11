Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'sites#index'

  get 'site/new', to: 'sites#new'
  post 'site/create', to: 'sites#create'
  get 'site/:id', to: 'sites#show', as: 'site'
  get 'sites', to: 'sites#index'
  delete 'sites/:id', to: 'sites#destroy', as: 'site_destroy'

  get 'crawl/:id', to: 'sites#crawl', as: 'crawl'


  get 'page/:id', to: 'pages#show', as: 'page'
  get 'compte_rendu/:id', to: 'pages#compte_rendu', as: 'compte_rendu'

  get 'sitemap/:id', to: 'sites#sitemap', as: 'sitemap'
  # create routes for sitemap.xml

end
