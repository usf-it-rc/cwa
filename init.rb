require 'redmine'
require 'simple_cas_validator'
require 'cwa'
require 'redmine_omniauth_cas'
require 'ipagroup'
require 'cwa_constants'
require_dependency 'cwa/hooks'
require 'googlecharts'

Redmine::MenuManager.map :project_menu do |menu|
  menu.delete :wiki if menu.exists? :wiki
  menu.delete :activity if menu.exists? :activity
  menu.delete :calendar if menu.exists? :calendar
end

Redmine::Plugin.register :cwa do
  name 'Cluster Web Access plugin'
  author 'Brian Smith'
  description 'This plugin provides tools and features useful for HPC' 
  version '0.0.1'
  url 'https://redmine.rc.usf.edu/projects/jobman'
  author_url 'http://blah'

  settings :default => { 
    'tos' => "", 
    'saa' => "",  
    'pwd_agreement' => "",
    'delete_saa' => "",
    'ipa_server' => "ipa.example.com",
    'ipa_account' => "ipa-service-account",
    'ipa_password' => "",
    'msg_url' => "sync.example.com",
    'msg_user' => "msg-service-account",
    'msg_password' => "",
    'project_id' => "default",
    'output_server' => "sftp.example.com",
    'production_cell_name' => "default",
    'testing_cell_name' => "testing",
  }, :partial => 'settings/cwa_settings'

  # TODO: Get permissions nailed down
  permission :cwa_accountsignup, { :cwa_accountsignup => [:index] }, :public => true
  permission :cwa_groupmanager, { :cwa_groupmanager => [:index] }, :public => true
  permission :cwa_jobmanager, { :cwa_jobmanager => [:index] }, :public => true
  permission :cwa_tutorials, { :cwa_tutorials => [:index] }, :public => true
  permission :cwa_allocations, { :cwa_allocations => [:index] }, :public => true
  permission :cwa_applications, { :cwa_applications => [:index] }, :public => true
#  permission :cwa_dashboard, { :cwa_dashboard => [:index] }, :public => true

  menu :project_menu, :cwa_accountsignup, { :controller => 'cwa_accountsignup', :action => 'index' }, 
       :caption => 'My Access', :after => :activity
  menu :project_menu, :cwa_allocations, { :controller => 'cwa_allocations', :action => 'index' }, 
       :caption => 'Allocations', :after => :cwa_accountsignup
  menu :project_menu, :cwa_groupmanager, { :controller => 'cwa_groupmanager', :action => 'index' }, 
       :caption => 'Groups', :after => :cwa_allocations
  menu :project_menu, :cwa_applications, { :controller => 'cwa_applications', :action => 'index' }, 
       :caption => 'Web Apps', :after => :cwa_groupmanager
  menu :project_menu, :cwa_jobmanager, { :controller => 'cwa_jobmanager', :action => 'index' }, 
       :caption => 'My Jobs', :after => :app_manager
  menu :project_menu, :wiki, { :controller => 'wiki', :action => 'show', :id => nil }, :param => :project_id,
       :caption => 'Documentation', :after => :cwa_jobmanager, :if => Proc.new { |p| p.wiki && !p.wiki.new_record? }
#  menu :project_menu, :cwa_tutorials, { :controller => 'cwa_tutorials', :action => 'index' }, 
#       :caption => 'Tutorials', :after => :cwa_jobmanager
#  menu :project_menu, :cwa_dashboard, { :controller => 'cwa_dashboard', :action => 'index' }, 
#       :caption => 'Dashboard', :after => :app_manager
end

Redmine::MenuManager.map :top_menu do |menu|
  menu.delete :home if menu.exists? :home
  menu.delete :my_page
  menu.delete :projects
  menu.delete :administration
  menu.push "Home", { :controller => 'projects', :action => 'show', :id => "research-computing" }
  menu.push :administration, { :controller => 'admin', :action => 'index' }, :last => true, 
            :if => Proc.new { |p| User.current.admin? }
  menu.delete :help
end

Redmine::MenuManager.map :account_menu do |menu|
  menu.delete :register
  menu.delete :my_account
end
