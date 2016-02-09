Rails.application.routes.draw do
  get 'slots/show'

  # REVIEW are these needed?
  get 'home/index'
  get 'home/about'

  resources :slots

  root to: 'home#index'

  # patch 'slot/:id/save_filter_rule' => 'slot#save_filter_rule', as: :save_filters
  post 'slots/:slot_id/assign_card/:id' => 'slots#assign_card', as: :assign_card
  # post 'slots/:slot_id/assign_filter/' => 'slots#assign_filter', as: :assign_filter
  post 'slots/:slot_id/assign_filter/' => 'slots#assign_filter', as: :assign_filter
  # delete 'slots/:slot_id/delete_filter/' => 'slots#delete_filter', as: :delete_filter
  patch 'slots/:slot_id/delete_filter/' => 'slots#delete_filter', as: :delete_filter
  post 'home/generate_cards/' => 'home#generate_cards', as: :generate_cards
end
