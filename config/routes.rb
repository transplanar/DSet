Rails.application.routes.draw do
  # REVIEW are these needed?
  get 'home/index'
  get 'home/about'

  root to: 'home#index'
end
