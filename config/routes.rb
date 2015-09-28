Rails.application.routes.draw do
  root 'home#top'

  get '/top', to: 'home#top'
  post '/like', to: 'home#like'
end
