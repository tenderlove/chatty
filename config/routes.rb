Chatty::Application.routes.draw do
  resources :messages
  root to: 'messages#show'
end
