module Redmine::CwaApplicationHelper
  class << self
    def cwa_applications_tabs
      tabs = [{:name => 'basic', :partial => 'cwa_applications/basic', :label => :cwa_application_basic_tab},
              {:name => 'exec_code', :partial => 'cwa_applications/exec', :label => :cwa_application_exec_tab},
              {:name => 'haml_code', :partial => 'cwa_applications/haml', :label => :cwa_application_haml_tab}]
    end
  end
end
