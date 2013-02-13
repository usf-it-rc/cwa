# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get 'cwa_accountsignup', :to => 'cwa_accountsignup#index'
get 'cwa_groupmanager', :to => 'cwa_groupmanager#index'
get 'cwa_groupmanager/groups', :to => 'cwa_groupmanager#groups'
get 'cwa_groupmanager/show', :to => 'cwa_groupmanager#show'
get 'cwa_groupmanager/create', :to => 'cwa_groupmanager#create'
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
match 'cwa_groupmanager/add', :to => 'cwa_groupmanager#add', :via => :post
match 'cwa_groupmanager/delete', :to => 'cwa_groupmanager#delete', :via => :post
match 'cwa_groupmanager/disband', :to => 'cwa_groupmanager#disband', :via => :post
match 'cwa_groupmanager/save_request', :to => 'cwa_groupmanager#save_request', :via => :post
match 'cwa_groupmanager/delete_request', :to => 'cwa_groupmanager#delete_request', :via => :post
match 'cwa_groupmanager/allow_join', :to => 'cwa_groupmanager#allow_join', :via => :post
match 'cwa_groupmanager/create_group', :to => 'cwa_groupmanager#create_group', :via => :post
match 'cwa_groupmanager/delete_group', :to => 'cwa_groupmanager#delete_group', :via => :post
