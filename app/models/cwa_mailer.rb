class CwaMailer < ActionMailer::Base
  default :from => "#{Project.find(Redmine::Cwa.project_id).name} <do-not-reply@rc.usf.edu>"

  def activation(user)
    @user = user
    mail(
      :to => "#{@user.firstname} #{@user.lastname} <#{@user.mail}>", 
      :subject => "RC@USF Access Activation"
      )
  end

  def deactivation(user)
    @user = user
    mail(
      :subject => "RC@USF Access De-activation",
      :to => "#{@user.firstname} #{@user.lastname} <#{@user.mail}>"
      )
  end

  def shell_change(user)
    @user = user
    mail(
      :subject => "RC@USF System Access Login Shell Change",
      :to => "#{@user.firstname} #{@user.lastname} <#{@user.mail}>"
    )
  end

  def allocation_submit_confirmation(user, allocation)
    @user = user
    @allocation = allocation
    mail(
      :subject => "RC@USF Allocation Submission Confirmation",
      :to => "#{@user.firstname} #{@user.lastname} <#{@user.mail}>"
      )
  end
  
  def allocation_approval(user, allocation)
    @user = user
    @allocation = allocation
    mail(
      :subject => "RC@USF Allocation Status Update",
      :to => "#{@user.firstname} #{@user.lastname} <#{@user.mail}>"
      )
  end

  def allocation_rejection(user, allocation)
    @user = user
    @allocation = allocation
    mail(
      :subject => "RC@USF Allocation Status Update",
      :to => "#{@user.firstname} #{@user.lastname} <#{@user.mail}>"
      )
  end

  def group_member_leave(user, group)
    @user = user
    @group = group
    mail(
      :subject => "RC@USF Group Leave Notification",
      :to => "#{@user.firstname} #{@user.lastname} <#{@user.mail}>"
      )
  end

  def group_member_request(group_owner, group_name)
    @group_owner = group_owner
    @group_name  = group_name
    @project = Project.find(Redmine::Cwa.project_id)
    mail(:subject => "RC@USF Group Join Request Notification",
         :to => "#{group_owner.firstname} #{group_owner.lastname} <#{group_owner.mail}>")
  end

  def group_add_member(user, group)
    @user = User.find_by_login(user)
    @group = group
    @project = Project.find(Redmine::Cwa.project_id)
    mail(:to => "#{@user.firstname} #{@user.lastname} <#{@user.mail}>",
         :subject => "RC@USF You've been added to a group!")
  end

  def group_remove_member(user, group)
    @user = user
    @group = group
    mail(:to => "#{@user.firstname} #{@user.lastname} <#{@user.mail}>",
         :subject => "RC@USF You've been removed from a group!")
  end
end
