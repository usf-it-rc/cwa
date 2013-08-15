require 'rsgejobs.rb'
require 'rsgequeue.rb'
require 'rsgehost.rb'

class CwaJobmanagerController < ApplicationController
  unloadable
 
  include CwaIpaAuthorize 

  before_filter :find_project, :authorize, :ipa_authorize
  accept_api_auth :index, :alljobs, :queue_status, :delete, :submit

  def index
    @jobs = RsgeJobs.new @user.login
    respond_to do |format|
      format.html
      format.json { render :json => @jobs.to_hash }
    end
  end

  def alljobs
    @jobs = RsgeJobs.new nil
    respond_to do |format|
      format.json { render :json => @jobs.to_hash }
    end
  end

  def current_jobs
    @jobs = Rails.cache.fetch("cached_job_list_#{@user.login}", :expires_in => 5.seconds) do
      RsgeJobs.new @user.login
    end
    render :partial => 'cwa_jobmanager/current_jobs'
  end

  def queue_status
    render :partial => 'cwa_jobmanager/queue_status'
  end

  def job_history
    @jobs = Rails.cache.fetch("cached_job_list_#{@user.login}", :expires_in => 5.seconds) do
      RsgeJobs.new @user.login
    end
    render :partial => 'cwa_jobmanager/job_history'
  end

  def delete
    jobs = RsgeJobs.new @user.login
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

    if params.has_key?(:app_id)
      @app = CwaApplication.find(params[:app_id])
    end

    Rails.logger.debug "CwaJobmanager.submit() => " + params.to_s

    # Sanitize the job name
    if params.has_key?(:job_name)
      if params[:job_name] !~ ::CwaConstants::JOBNAME_REGEX
        flash[:error] = "Invalid job name specified!"
        redirect_to :controller => 'cwa_applications', :action => 'display', :id => params[:app_id], :project_id => params[:project_id]
        return
      end
      @job.job_name = params[:job_name]
    end

    

    # sanitize the selected_file parameter
    if params[:selected_file] != nil
      if params[:selected_file] !~ ::CwaConstants::JOBPATH_REGEX
        flash[:error] = "Invalid job file specified! Make sure you're using forward-slash \"/\"!"
        redirect_to :controller => 'cwa_applications', :action => 'display', :id => params[:app_id], :project_id => params[:project_id]
        return
      end
      #params[:selected_dir] = params[:selected_file].gsub(/(.*)\/.*$/, '\1')
    end

    #if params[:selected_dir] == nil && params[:current_dir] != nil
    #  params[:selected_dir] = params[:current_dir]
    #end

    # And selected_dir
    if params[:selected_dir] !~ ::CwaConstants::JOBPATH_REGEX
      flash[:error] = "Invalid job directory specified! Make sure you're using forward-slash \"/\"!"
      redirect_to :controller => 'cwa_applications', :action => 'display', :id => params[:app_id], :project_id => params[:project_id]
      return
    end

    if !@app.nil?
      script = @app.exec.gsub(/\r\n/, "\n")
    else
      script = Base64.decode64(params[:script])
    end

    # Substitute out all %%KEY%% items in the job script, then assign
    params.except("utf8", "authenticity_token","commmit","action","script").keys.each do |k|
      script.gsub!(/%%#{k.upcase}%%/, params[k])
    end

    @job.script = script
    @job.job_owner = @user.login

    Rails.logger.debug "CwaJobmanager.submit() => " + @job.script

    begin
      @job.submit
    rescue Exception => e
      flash[:error] = e.message
    else
      flash[:notice] = "Submitted job"
    end

    CwaJobHistory.create :owner => @job.job_owner, :jobid => @job.jobid, :job_name => @job.job_name, :workdir => params['selected_dir'], :app_id => @app.nil? ? nil : @app.id, :submit_parameters => params.except("utf8","authenticity_token","commit","action").to_json.to_s
      
    respond_to do |format|
      format.html { redirect_to :action => 'index', :project_id => params[:project_id] }
      format.json { render :json => { :id => @job.jobid, :status => status, :state => @job.state } }
    end
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  end

  def resolve_path(share,path)
    if path != nil
      case share
      when "home"
        file = @ipa_user.homedirectory + "/" + path
      when "work"
        file = @ipa_user.workdirectory + "/" + path
      when "shares"
        file = "/shares/" + path
      end
    else
      case share
      when "home"
        file = @ipa_user.homedirectory
      when "work"
        file = @ipa_user.workdirectory
      when "shares"
        file = nil
      end
    end
    file
  end

end
