Rails.application.routes.draw do
  # confirmの追加
  get '/confirm/:id', to: 'posts#confirm', as: :confirm
  # only以下追記
  resources :posts, only: [:create, :show, :edit, :update]
  # トップページにアクセスした際に postコントローラのnewアクションを呼び出す設定
  root to: "posts#new"
end
