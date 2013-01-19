Redmine::Plugin.register :cwa_as do
  name 'CWA System Access Sign-up plugin'
  author 'Author name'
  description 'This plugin uses JSON-RPC to provision an account in FreeIPA after agreeing to ToS and SAA'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
  menu :account_menu, :cwa_as, { :controller => 'cwa_as', :action => 'index' }, :caption => 'My Account'
  settings :default => {
    :saa => "Service Access Agreement goes here",
    :tos => "Terms of Service go here" }, :partial => 'settings/cwaas_settings'
end
