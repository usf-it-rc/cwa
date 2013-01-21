# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get 'cwa_as', :to => 'cwa_as#index'
get 'cwa_as/failure', :to => 'cwa_as#failure'
get 'cwa_as/no_auth', :to => 'cwa_as#no_auth'
get 'cwa_as/user_info', :to => 'cwa_as#user_info'
match 'cwa_as/create', :to => 'cwa_as#create', :via => :post
match 'cwa_as/user_shell', :to => 'cwa_as#user_shell', :via => :post
