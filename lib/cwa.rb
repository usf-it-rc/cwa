# Simply adding accessors to make the CWA plugin options available globally
# throughout the classes and modules of the plugin
module Redmine::Cwa
  class << self
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
