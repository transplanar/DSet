Rails.application.routes.draw do
  get 'slots/show'

  # REVIEW are these needed?
  get 'home/index'
  get 'home/about'

  resources :slots

  root to: 'home#index'

  # patch 'slot/:id/save_filter_rule' => 'slot#save_filter_rule', as: :save_filters
  post 'slots/:slot_id/assign_card/:id' => 'slots#assign_card', as: :assign_card
end
