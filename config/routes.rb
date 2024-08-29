Rails.application.routes.draw do

  resources :instruments
  resources :records

  resource :records do
    get 'record/indexall' => 'records#indexall'
    post 'record/upload' => 'records#upload'
  end

  mount Blacklight::Engine => '/'
  mount BlacklightAdvancedSearch::Engine => '/'

  get 'advanced' => 'advanced#index', as: 'advanced_search'


  root to: "catalog#index"
  concern :searchable, Blacklight::Routes::Searchable.new

  get 'privacy' => 'catalog#privacy', as: 'privacy'

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  devise_for :users
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  # search for instrument by id
  resource :catalog do
    get 'instrument/:id' => 'instruments#search', :as => 'instrument_search'
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
