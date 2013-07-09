# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

# Account Signup
get 'cwa_accountsignup/:project_id', :to => 'cwa_accountsignup#index'
get 'cwa_accountsignup/:project_id/user_info', :to => 'cwa_accountsignup#user_info'
match 'cwa_accountsignup/:project_id/create', :to => 'cwa_accountsignup#create', :via => :post
match 'cwa_accountsignup/:project_id/set_shell', :to => 'cwa_accountsignup#set_shell', :via => :post
match 'cwa_accountsignup/:project_id/delete', :to => 'cwa_accountsignup#delete', :via => :post

# Group Manager
get 'cwa_groupmanager/:project_id', :to => 'cwa_groupmanager#index'
get 'cwa_groupmanager/:project_id/all', :to => 'cwa_groupmanager#groups'
get 'cwa_groupmanager/:project_id/show/:group_name', :to => 'cwa_groupmanager#show', group_name: /[a-zA-Z0-9\-\._\ ]{2,20}/
get 'cwa_groupmanager/:project_id/create', :to => 'cwa_groupmanager#create'
match 'cwa_groupmanager/:project_id/add', :to => 'cwa_groupmanager#add', :via => :post
match 'cwa_groupmanager/:project_id/delete', :to => 'cwa_groupmanager#delete', :via => :post
match 'cwa_groupmanager/:project_id/disband', :to => 'cwa_groupmanager#disband', :via => :post
match 'cwa_groupmanager/:project_id/save_request', :to => 'cwa_groupmanager#save_request', :via => :post
match 'cwa_groupmanager/:project_id/delete_request', :to => 'cwa_groupmanager#delete_request', :via => :post
match 'cwa_groupmanager/:project_id/allow_join', :to => 'cwa_groupmanager#allow_join', :via => :post
match 'cwa_groupmanager/:project_id/create_group', :to => 'cwa_groupmanager#create_group', :via => :post
match 'cwa_groupmanager/:project_id/delete_group', :to => 'cwa_groupmanager#delete_group', :via => :post

# Job Manager
get 'cwa_jobmanager/:project_id', :to => 'cwa_jobmanager#index'
get 'cwa_jobmanager/:project_id/current_jobs', :to => 'cwa_jobmanager#current_jobs'
get 'cwa_jobmanager/:project_id/queue_status', :to => 'cwa_jobmanager#queue_status'
get 'cwa_jobmanager/:project_id/job_history', :to => 'cwa_jobmanager#job_history'
match 'cwa_jobmanager/:project_id/submit', :to => 'cwa_jobmanager#submit', :via => :post
match 'cwa_jobmanager/:project_id/delete', :to => 'cwa_jobmanager#delete', :via => :post

# Applications
get 'cwa_applications/:project_id', :to => 'cwa_applications#index', :as => :cwa_applications
get 'cwa_applications/:project_id/new', :to => 'cwa_applications#new'
get 'cwa_applications/:project_id/:id', :to => 'cwa_applications#display'
get 'cwa_applications/:project_id/edit/:id', :to => 'cwa_applications#show', :as => :cwa_application
match 'cwa_applications/:project_id/new', :to => 'cwa_applications#new', :via => :post
match 'cwa_applications/:project_id/edit/:id', :to => 'cwa_applications#update', :via => :put
match 'cwa_applications/:project_id/delete/:id', :to => 'cwa_applications#delete', :via => :delete

# Allocations
get 'cwa_allocations/:project_id', :to => 'cwa_allocations#index'
get 'cwa_allocations/:project_id/admin', :to => 'cwa_allocations#admin'
get 'cwa_allocations/:project_id/form', :to => 'cwa_allocations#form'
match 'cwa_allocations/:project_id/submit', :to => 'cwa_allocations#submit', :via => :post
match 'cwa_allocations/:project_id/delete', :to => 'cwa_allocations#delete', :via => :post
match 'cwa_allocations/:project_id/update', :to => 'cwa_allocations#update', :via => :post

# Default
get 'cwa_default/:project_id/not_activated', :to => 'cwa_default#not_activated'
get 'cwa_default/:project_id/unavailable', :to => 'cwa_default#unavailable'
get 'cwa_default/:project_id/authorization', :to => 'cwa_default#authorization'

# Browser
get 'cwa_browser/:project_id', :to => 'cwa_browser#index'
get 'cwa_browser/:project_id/download', :to => 'cwa_browser#get'
get 'cwa_browser/:project_id/download_zip', :to => 'cwa_browser#get_zip'
#get 'cwa_browser/:project_id/rename', :to => 'cwa_browser#rename'
get 'cwa_browser/:project_id/delete', :to => 'cwa_browser#delete'
#get 'cwa_browser/:project_id/tail', :to => 'cwa_browser#tail'
get 'cwa_browser/:project_id/mkdir', :to => 'cwa_browser#mkdir'
match 'cwa_browser/:project_id/create', :to => 'cwa_browser#create', :via => :post
match 'cwa_browser/:project_id/upload', :to => 'cwa_browser#upload', :via => :post
#match 'cwa_browser/:project_id/*', :to => 'cwa_browser#handler'
#
# Try to define REST api like so:
#
# ./<home|shares|work>/path/to/file/<method>
#match 'cwa_browser/:project_id/*/mkdir', :via => :post, :to => 'cwa_browser#mkdir'
#match 'cwa_browser/:project_id/*/content', :via => :post, :to => 'cwa_browser#get'
#match 'cwa_browser/:project_id/*/rename', :via => :post, :to => 'cwa_browser#rename'
post 'cwa_browser/:project_id/*share/*file/rename/*new_name', 
  :to => 'cwa_browser#rename',
  :file => /[^\0]+/,
  :new_name => /[^\0]+/,
  :share => /(home|shares|work)/
post 'cwa_browser/:project_id/*share/*file/tail', 
  :to => 'cwa_browser#tail',
  :file => /[^\0]+/,
  :share => /(home|shares|work)/
#match 'cwa_browser/:project_id/*/zip', :via => :post, :to => 'cwa_browser#get_zip'
#match 'cwa_browser/:project_id/*/mkdir', :via => :post, :to => 'cwa_browser#mkdir'
#match 'cwa_browser/:project_id/*/create', :via => :post, :to => 'cwa_browser#create'
#match 'cwa_browser/:project_id/*', :via => :put, :to => 'cwa_browser#upload'
#match 'cwa_browser/:project_id/*', :via => :delete, :to => 'cwa_browser#delete'
get 'cwa_browser/:project_id/*share/*dir', :to => 'cwa_browser#index',
  :share => /(home|shares|work)/,
  :dir => /[^\0]+/
get 'cwa_browser/:project_id/*share', :to => 'cwa_browser#index',
  :share => /(home|shares|work)/

# Stats browser
get 'cwa_stats/:project_id', :to => 'cwa_stats#index'
#get 'cwa_stats/system/:project_id', :to => 'cwa_stats#ganglia'
#resources 'cwa_stats/:project_id', :only => [:index, :new, :edit, :create, :delete, :show, :update]
