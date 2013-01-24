require 'redmine'
require 'simple_json_rpc'
require 'simple_cas_validator'

Redmine::Plugin.register :cwa_as do
  name 'CWA System Access Sign-up plugin'
  author 'Author name'
  description 'This plugin uses JSON-RPC to provision an account in FreeIPA after agreeing to ToS and SAA'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
  settings :default => {
    :saa => "Service Access Agreement goes here",
    :tos => "Terms of Service go here" }, :partial => 'settings/cwaas_settings'
  permission :cwa_as, { :cwa_as => [:index] }, :public => true
  menu :project_menu, :cwa_as, { :controller => 'cwa_as', :action => 'index' }, :caption => 'Account Management', :after => :activity
end

Redmine::MenuManager.map :project_menu do |menu|
  menu.delete :activity if menu.exists? :activity
  menu.delete :calendar if menu.exists? :calendar
end

Redmine::MenuManager.map :top_menu do |menu|
  menu.delete :home if menu.exists? :home
  menu.delete :my_page
  menu.delete :projects
  menu.delete :administration
  menu.push :administration, { :controller => 'admin', :action => 'index' }, :last => true, 
            :if => Proc.new { |p| User.current.admin? }
  menu.delete :help
end

Redmine::MenuManager.map :account_menu do |menu|
  menu.delete :register
  menu.delete :my_account
end
