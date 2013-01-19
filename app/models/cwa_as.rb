class CwaAs < ActiveRecord::Base
  #attr_accessible :tos, :saa, :delete_saa
  def saa
    Setting.plugin_cwa_as[:saa]
  end
  def tos 
    Setting.plugin_cwa_as[:tos]
  end
  def pwd_agreement
    Setting.plugin_cwa_as[:pwd_agreement]
  end
  def ipa_server
    Setting.plugin_cwa_as[:ipa_server]
  end
  def ipa_account
    Setting.plugin_cwa_as[:ipa_account]
  end
  def ipa_password
    Setting.plugin_cwa_as[:ipa_password]
  end
  def delete_saa 
    Setting.plugin_cwa_as[:delete_saa]
  end
end
