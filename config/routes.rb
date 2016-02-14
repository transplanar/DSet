Rails.application.routes.draw do
  get 'home/index'
  get 'home/about', as: :about

  post 'home/generate_cards/' => 'home#generate_cards', as: :generate_cards
  post 'home/clear_filters/' => 'home#clear_filters', as: :clear_filters

  resources :slots
  post 'slots/:slot_id/assign_card/:id' => 'slots#assign_card', as: :assign_card
  post 'slots/:slot_id/assign_filter/' => 'slots#assign_filter', as: :assign_filter
  patch 'slots/:slot_id/delete_filter/' => 'slots#delete_filter', as: :delete_filter

  root to: 'home#index'
end
