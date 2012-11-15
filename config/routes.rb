Rails.application.routes.draw do
  scope constraints: { format: :js } do
    resources :uploads, only: [:destroy]
    controller :uploads do
      post 'uploadify' => :uploadify
    end
  end
end
