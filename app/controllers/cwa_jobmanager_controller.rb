require 'rsgejobs.rb'

class CwaJobmanagerController < ApplicationController
  unloadable

  def index
    @project = Project.find(Redmine::Cwa.project_id)
    @jobs = RsgeJobs.new User.current.login
    @user = CwaIpaUser.new
    (redirect_to :controller => 'cwa_default', :action => 'not_activated' and return) if !@user.provisioned?
    respond_to do |format|
      format.html
    end
  end

  def delete
    jobs = RsgeJobs.new User.current.login
    job = jobs.where_id_is params[:jobid]

    if job.delete
      flash[:notice] = "Job #{params[:jobid]} deleted!"
    else
      flash[:error] = "Problem deleting job #{params[:jobid]}!"
    end
    redirect_to :action => 'index'
  end

  def submit
    @job = RsgeJob.new
    @app = CwaApplication.find(params[:app_id])

    Rails.logger.debug "CwaJobmanager.submit() => " + params.to_s

    if params.has_key?(:job_name)
      if params[:job_name] !~ ::CwaConstants::JOBNAME_REGEX
        flash[:error] = "Invalid job name specified!"
        redirect_to :controller => 'cwa_applications', :action => 'display', :id => params[:app_id]
        return
      end
      @job.job_name = params[:job_name]
    end

    if params[:job_dir] !~ ::CwaConstants::JOBPATH_REGEX
      flash[:error] = "Invalid job directory specified! Make sure you're using forward-slash \"/\"!"
      redirect_to :controller => 'cwa_applications', :action => 'display', :id => params[:app_id]
      return
    end

    script = @app.exec.gsub(/\r\n/, "\n")

    # Substitute out all %%KEY%% items in the job script, then assign
    params.keys.each do |k|
      script.gsub!(/%%#{k.upcase}%%/, params[k])
    end

    @job.script = script
    @job.job_owner  = User.current.login

    Rails.logger.debug "CwaJobmanager.submit() => " + @job.script

    if @job.submit
      flash[:notice] = "Submitted job"
    else
      flash[:error] = "Problem submitting job"
    end

    CwaJobHistory.create :owner => @job.job_owner, :jobid => @job.jobid, :job_name => @job.job_name, :workdir => params['job_dir']
      
    redirect_to :action => 'index'
  end

end
