class CwaAs < ActiveRecord::Base
  # This gets us all of our accessor methods for plugin settings
  # and ipa-based attributes
  @@fields = nil
  @@ipa_record = nil

  def method_missing(name, *args, &blk)
    if args.empty? && blk.nil? && Setting.plugin_cwa_as.has_key?(name)
      Setting.plugin_cwa_as[name]
    elsif args.empty? && blk.nil? 
      make_user_fields if @@fields == nil
      if @@ipa_record == nil
        @@ipa_record = ipa_query(User.current.login.downcase)['result'] 
      end
      # return if valid ipa record
      if @@ipa_record.has_key?(name.to_s)
        @@ipa_record[name.to_s].to_a.join
      # return if valid custom_field
      elsif @@fields.has_key?(name.to_sym)
        @@fields[name.to_sym]
      else
        super
      end
    else
      super
    end
  end

  # List of allowed shells
  def shells
     { "/bin/sh" => 0, "/bin/bash" => 1, "/bin/ash" => 2, "/bin/zsh" => 3,  "/bin/csh" => 4, "/bin/tcsh" => 5 }
  end

  # Set user shell
  def set_loginshell(shell)
    user_set(User.current.login.downcase, { :loginshell => shell })
  end

  # Get wonderful attributes from IPA server
  def ipa_query(user)
    if @ipa_user == nil
      json_string = <<EOF
{ "method": "user_show", 
  "params":[
   [],
   { "uid":"#{user}" }
   ] 
}
EOF
      begin
        r = Redmine::CwaAs.simple_json_rpc(
          "https://" + ipa_server + "/ipa/json", 
          ipa_account,
          ipa_password,
          json_string
        )
      rescue Exception => e
        raise e.message
      else
        @ipa_user = r['result']
      end
    end
    @ipa_user
  end

  # Wrap around ipa_query to give a true/false for whether the user exists
  def ipa_exists?
    begin
      r = ipa_query(User.current.login.downcase) 
    rescue Exception => e
      raise e.message 
    end 
    r != nil ? true : false
  end

  # update user parameters in IPA
  def user_set(user,params)
    json_string = <<EOF
{ "method": "user_mod", 
  "params":[
   [],
    { 
     "uid":"#{user}",
EOF

    p_keys = params.keys
    last = p_keys.pop
    params.keys.each do |k|
      json_string += "     \"#{k.to_s}\":\"#{params[k]}\",\n" 
    end

    json_string += <<EOF 
     "#{last.to_s}":"#{params[last]}"
    }
   ] 
}
EOF
    logger.debug ipa_server + "/ipa/json"
    Redmine::CwaAs.simple_json_rpc(
      "https://" + ipa_server + "/ipa/json", 
      ipa_account,
      ipa_password,
      json_string
    )
  end

  def make_user_fields
    @@fields = Hash.new
    User.current.available_custom_fields.each do |field|
      @@fields[field.name.to_sym] = User.current.custom_field_value(field.id)
    end
  end
end
