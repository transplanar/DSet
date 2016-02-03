Rails.application.routes.draw do
  get 'slots/show'

  # get 'slot/new'

  # get 'slot/create'

  # get 'slot/update'

  # get 'slot/edit'

  # REVIEW are these needed?
  get 'home/index'
  get 'home/about'

  resources :slots

  root to: 'home#index'

  patch 'slot/:id/save_filter_rule' => 'slot#save_filter_rule', as: :save_filters
end
