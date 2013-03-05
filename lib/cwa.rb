# Simply adding accessors to make the CWA plugin options available globally
# throughout the classes and modules of the plugin
module Redmine::Cwa
  @USER_REGEX = /^[a-zA-Z0-9-]{3,20}$/
  @GROUP_REGEX = /^[a-zA-Z0-9-\._]{3,20}$/
  @PASSWD_REGEX = /[0-9A-Za-z\!@#\$%\^&\(\)-_=\+|\[\]\{\};:\/\?\.\>\<]{8,}$/
  @JOBNAME_REGEX = /^[a-zA-Z0-9-_\.]{1,128}$/
  @JOBPATH_REGEX = /^[\/a-zA-Z0-9-_\.]{1,4096}$/

  class << self
    attr_reader :USER_FIELD_REGEX, :GROUP_FIELD_REGEX, :PASSWD_FIELD_REGEX
    def settings_hash
      Setting["plugin_cwa"]
    end

    # If its an option in the settings hash, return it
    def method_missing(name, *args, &blk)
      if args.empty? && blk.nil? && settings_hash.has_key?(name.to_sym)
        settings_hash[name.to_sym]
      else
        nil
      end
    end
  end
end
