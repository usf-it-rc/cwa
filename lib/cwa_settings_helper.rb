module Redmine::CwaSettingsHelper
  class << self
    def cwa_settings_tab
      tabs = [{:name => 'main', :partial => 'cwa_settings/main', :label => :settings_main_tab},
              {:name => 'storage', :partial => 'cwa_settings/storage', :label => :settings_storage_tab},
              {:name => 'scheduler', :partial => 'cwa_settings/scheduler', :label => :settings_scheduler_tab},
              {:name => 'ldap', :partial => 'cwa_settings/ldap', :label => :settings_ldap_tab},
              {:name => 'domain', :partial => 'cwa_settings/trusts', :label => :settings_trust_tab}]
    end
  end
end
