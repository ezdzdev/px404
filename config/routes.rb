Rails.application.routes.draw do
  root 'home#home'

  get '/top', to: 'home#top'
end
