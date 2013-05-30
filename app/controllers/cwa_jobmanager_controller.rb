require 'rsgejobs.rb'
require 'rsgequeue.rb'
require 'rsgehost.rb'

class CwaJobmanagerController < ApplicationController
  unloadable

  def index
    @project = Project.find(params[:project_id])
    @jobs = RsgeJobs.new User.current.login
    @user = CwaIpaUser.new
    (redirect_to :controller => 'cwa_default', :action => 'not_activated' and return) if !@user.provisioned?
    respond_to do |format|
      format.html
    end
  end

  def current_jobs
    user = User.current.login
    @jobs = Rails.cache.fetch("cached_job_list_#{user}", :expires_in => 5.seconds) do
      RsgeJobs.new(user)
    end
    render :partial => 'cwa_jobmanager/current_jobs'
  end

  def queue_status
    render :partial => 'cwa_jobmanager/queue_status'
  end

  def job_history
    user = User.current.login
    @jobs = Rails.cache.fetch("cached_job_list_#{user}", :expires_in => 5.seconds) do
      RsgeJobs.new(user)
    end
    render :partial => 'cwa_jobmanager/job_history'
  end

  def delete
    jobs = RsgeJobs.new User.current.login
    job = jobs.where_id_is params[:jobid]

    if job.delete
      flash[:notice] = "Job #{params[:jobid]} deleted!"
    else
      flash[:error] = "Problem deleting job #{params[:jobid]}!"
    end
    redirect_to :action => 'index', :project_id => params[:project_id]
  end

  def submit
    @job = RsgeJob.new
    @app = CwaApplication.find(params[:app_id])

    Rails.logger.debug "CwaJobmanager.submit() => " + params.to_s

    if params.has_key?(:job_name)
      if params[:job_name] !~ ::CwaConstants::JOBNAME_REGEX
        flash[:error] = "Invalid job name specified!"
        redirect_to :controller => 'cwa_applications', :action => 'display', :id => params[:app_id], :project_id => params[:project_id]
        return
      end
      @job.job_name = params[:job_name]
    end

    if params[:selected_file] != nil
      if params[:selected_file] !~ ::CwaConstants::JOBPATH_REGEX
        flash[:error] = "Invalid job file specified! Make sure you're using forward-slash \"/\"!"
        redirect_to :controller => 'cwa_applications', :action => 'display', :id => params[:app_id], :project_id => params[:project_id]
        return
      end
      params[:selected_dir] = params[:selected_file].gsub(/(.*)\/.*$/, '\1')
    end

    if params[:selected_dir] == nil && params[:current_dir] != nil
      params[:selected_dir] = params[:current_dir]
    end

    if params[:selected_dir] !~ ::CwaConstants::JOBPATH_REGEX
      flash[:error] = "Invalid job directory specified! Make sure you're using forward-slash \"/\"!"
      redirect_to :controller => 'cwa_applications', :action => 'display', :id => params[:app_id], :project_id => params[:project_id]
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

    begin
      @job.submit
    rescue Exception => e
      flash[:error] = e.message
    else
      flash[:notice] = "Submitted job"
    end

    CwaJobHistory.create :owner => @job.job_owner, :jobid => @job.jobid, :job_name => @job.job_name, :workdir => params['selected_dir'], :app_id => @app.id, :submit_parameters => params.except("utf8","authenticity_token","commit","action").to_json.to_s
      
    redirect_to :action => 'index', :project_id => params[:project_id]
  end

end
