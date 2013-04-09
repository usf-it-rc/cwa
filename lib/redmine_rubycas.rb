module Redmine::RubyCAS
  class << self
    def settings_hash
      Setting["plugin_redmine_rubycas"]
    end

    def method_missing(name, *args, &blk)
    # If its an option in the settings hash, return it
      if args.empty? && blk.nil? && settings_hash.has_key?(name.to_sym)
        settings_hash[name.to_sym]
      else
        nil
      end
    end
  end
end
