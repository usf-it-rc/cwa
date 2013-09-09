module CwaIpaAuthorize
  def ipa_authorize
    @ipa_user = CwaIpaUser.new
    @user = @ipa_user.user

    if @ipa_user.provisioned? and @user != nil
      Rails.logger.debug "ipa_authorize: User #{@ipa_user.uid} provisioned"
    else
      redirect_to :controller => 'cwa_default', :action => 'not_activated'
      return
    end
  end
end
