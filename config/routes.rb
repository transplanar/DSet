Rails.application.routes.draw do
  # get 'slot/new'

  # get 'slot/create'

  # get 'slot/update'

  # get 'slot/edit'

  # REVIEW are these needed?
  get 'home/index'
  get 'home/about'

  resources :slots

  root to: 'home#index'
end
