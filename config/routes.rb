# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get 'cwa_accountsignup', :to => 'cwa_accountsignup#index'
get 'cwa_groupmanager', :to => 'cwa_groupmanager#index'
get 'cwa_groupmanager/groups', :to => 'cwa_groupmanager#groups'
get 'cwa_groupmanager/show', :to => 'cwa_groupmanager#show'
get 'cwa_groupmanager/create', :to => 'cwa_groupmanager#create'
get 'cwa_jobmanager', :to => 'cwa_jobmanager#index'
get 'cwa_jobmanager/current_jobs', :to => 'cwa_jobmanager#current_jobs'
get 'cwa_jobmanager/queue_status', :to => 'cwa_jobmanager#queue_status'
get 'cwa_jobmanager/job_history', :to => 'cwa_jobmanager#job_history'
get 'cwa_applications', :to => 'cwa_applications#index'
get 'cwa_applications/new', :to => 'cwa_applications#new'
get 'cwa_tutorials', :to => 'cwa_tutorials#index'
get 'cwa_allocations', :to => 'cwa_allocations#index'
get 'cwa_allocations/admin', :to => 'cwa_allocations#admin'
get 'cwa_allocations/form', :to => 'cwa_allocations#form'
get 'cwa_accountsignup/failure', :to => 'cwa_accountsignup#failure'
get 'cwa_accountsignup/no_auth', :to => 'cwa_accountsignup#no_auth'
get 'cwa_accountsignup/user_info', :to => 'cwa_accountsignup#user_info'
get 'cwa_default/not_activated', :to => 'cwa_default#not_activated'
get 'cwa_browser', :to => 'cwa_browser#index'
get 'cwa_dashboard', :to => 'cwa_dashboard#index'
get 'cwa_browser/download', :to => 'cwa_browser#get'
match 'cwa_accountsignup/create', :to => 'cwa_accountsignup#create', :via => :post
match 'cwa_accountsignup/set_shell', :to => 'cwa_accountsignup#set_shell', :via => :post
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
match '/cwa_applications/delete/:id', :to => 'cwa_applications#delete', :via => :delete
match '/cwa_applications/:id', :to => 'cwa_applications#update', :via => :put
match '/cwa_applications/display/:id', :to => 'cwa_applications#display'
resources 'cwa_stats', :only => [:index, :new, :edit, :create, :delete, :show, :update]
resources 'cwa_applications', :only => [:create, :delete, :show, :update]
match '/cwa_jobmanager/submit', :to => 'cwa_jobmanager#submit', :via => :post
match 'cwa_jobmanager/delete', :to => 'cwa_jobmanager#delete', :via => :post
