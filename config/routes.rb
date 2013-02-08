# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get 'cwa_accountsignup', :to => 'cwa_accountsignup#index'
get 'cwa_groupmanager', :to => 'cwa_groupmanager#index'
get 'cwa_jobmanager', :to => 'cwa_jobmanager#index'
get 'cwa_tutorials', :to => 'cwa_tutorials#index'
get 'cwa_allocations', :to => 'cwa_allocations#index'
get 'cwa_allocations/admin', :to => 'cwa_allocations#admin'
get 'cwa_allocations/form', :to => 'cwa_allocations#form'
get 'cwa_accountsignup/failure', :to => 'cwa_accountsignup#failure'
get 'cwa_accountsignup/no_auth', :to => 'cwa_accountsignup#no_auth'
get 'cwa_accountsignup/user_info', :to => 'cwa_accountsignup#user_info'
match 'cwa_accountsignup/create', :to => 'cwa_accountsignup#create', :via => :post
match 'cwa_accountsignup/user_shell', :to => 'cwa_accountsignup#user_shell', :via => :post
match 'cwa_accountsignup/delete', :to => 'cwa_accountsignup#delete', :via => :post
match 'cwa_allocations/submit', :to => 'cwa_allocations#submit', :via => :post
match 'cwa_allocations/delete', :to => 'cwa_allocations#delete', :via => :post
match 'cwa_allocations/update', :to => 'cwa_allocations#update', :via => :post
