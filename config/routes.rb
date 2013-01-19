# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get 'cwa_as', :to => 'cwa_as#index'
get 'cwa_as/failure', :to => 'cwa_as#failure'
get 'cwa_as/create', :to => 'cwa_as#create'
