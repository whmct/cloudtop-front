CloudtopFront::Application.routes.draw do
  scope '1/' do
    resources :classes, except: [:new, :edit], path:'classes/:className' 
  end
end
