# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

# Account Signup
get 'cwa_accountsignup/:project_id', :to => 'cwa_accountsignup#index'
get 'cwa_accountsignup/:project_id/user_info', :to => 'cwa_accountsignup#user_info'
match 'cwa_accountsignup/:project_id/create', :to => 'cwa_accountsignup#create', :via => :post
match 'cwa_accountsignup/:project_id/set_shell', :to => 'cwa_accountsignup#set_shell', :via => :post
match 'cwa_accountsignup/:project_id/delete', :to => 'cwa_accountsignup#delete', :via => :post

# Group Manager
get 'cwa_groups/:project_id', :to => 'cwa_groups#index'
get 'cwa_groups/:project_id/all', :to => 'cwa_groups#groups'
get 'cwa_groups/:project_id/show/:group_name', :to => 'cwa_groups#show', group_name: /[a-zA-Z0-9\-\._\ ]{2,20}/
get 'cwa_groups/:project_id/create', :to => 'cwa_groups#create'
match 'cwa_groups/:project_id/add', :to => 'cwa_groups#add', :via => :post
match 'cwa_groups/:project_id/delete', :to => 'cwa_groups#delete', :via => :post
match 'cwa_groups/:project_id/disband', :to => 'cwa_groups#disband', :via => :post
match 'cwa_groups/:project_id/save_request', :to => 'cwa_groups#save_request', :via => :post
match 'cwa_groups/:project_id/delete_request', :to => 'cwa_groups#delete_request', :via => :post
match 'cwa_groups/:project_id/allow_join', :to => 'cwa_groups#allow_join', :via => :post
match 'cwa_groups/:project_id/create_group', :to => 'cwa_groups#create_group', :via => :post
match 'cwa_groups/:project_id/delete_group', :to => 'cwa_groups#delete_group', :via => :post

# Job Manager
get 'cwa_jobmanager/:project_id', :to => 'cwa_jobmanager#index'
get 'cwa_jobmanager/:project_id/all', :to => 'cwa_jobmanager#alljobs'
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

#
# Try to define REST api like so:
#
# ./<home|shares|work>/path/to/file/<method>
#
get 'cwa_browser/:project_id/download/:fid',
  :to => 'cwa_browser#get'

get 'cwa_browser/:project_id/downloadzip/:fid',
  :to => 'cwa_browser#get_zip'

# Creating new text files
post 'cwa_browser/:project_id/*share/create',
  :to => 'cwa_browser#create',
  :share => /(home|shares|work)/

post 'cwa_browser/:project_id/*share/*path/create',
  :to => 'cwa_browser#create',
  :share => /(home|shares|work)/,
  :path => /[^\0]+/

# Download methods
get 'cwa_browser/:project_id/download/:fid',
  :to => 'cwa_browser#get'

get 'cwa_browser/:project_id/downloadzip/:fid',
  :to => 'cwa_browser#get_zip'

post 'cwa_browser/:project_id/*share/*path/download',
  :to => 'cwa_browser#download',
  :share => /(home|shares|work)/

# Upload methods
post 'cwa_browser/:project_id/*share/upload',
  :to => 'cwa_browser#upload',
  :share => /(home|shares|work)/

post 'cwa_browser/:project_id/*share/*dir/upload',
  :to => 'cwa_browser#upload',
  #:path => /[^\0]+/,
  :share => /(home|shares|work)/

# Make directories
post 'cwa_browser/:project_id/*share/mkdir/*new_dir',
  :to => 'cwa_browser#mkdir',
  :new_dir => /[^\0]+/,
  :share => /(home|shares|work)/

post 'cwa_browser/:project_id/*share/*path/mkdir/*new_dir',
  :to => 'cwa_browser#mkdir',
#  :path => /[^\0]+/,
  :new_dir => /[^\0]+/,
  :share => /(home|shares|work)/

# Delete a file
post 'cwa_browser/:project_id/*share/*path/delete',
  :to => 'cwa_browser#delete',
  #:path => /[^\0]+/,
  :share => /(home|shares|work)/

# Rename a file
post 'cwa_browser/:project_id/*share/*file/rename/*new_name', 
  :to => 'cwa_browser#rename',
  :file => /[^\0]+/,
  :new_name => /[^\0]+/,
  :share => /(home|shares|work)/

# Tail a file
post 'cwa_browser/:project_id/*share/*file/tail', 
  :to => 'cwa_browser#tail',
  :file => /[^\0]+/,
  :share => /(home|shares|work)/

# Display a path
get 'cwa_browser/:project_id/*share/*dir', :to => 'cwa_browser#index',
  :share => /(home|shares|work)/,
  :dir => /[^\0]+/

# Display a path at the base of a share
get 'cwa_browser/:project_id/*share', :to => 'cwa_browser#index',
  :share => /(home|shares|work)/

# Stats browser
get 'cwa_stats/:project_id', :to => 'cwa_stats#index'
#get 'cwa_stats/system/:project_id', :to => 'cwa_stats#ganglia'
#resources 'cwa_stats/:project_id', :only => [:index, :new, :edit, :create, :delete, :show, :update]
