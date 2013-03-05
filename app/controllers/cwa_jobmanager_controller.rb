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

    @job.job_name = params[:job_name] if params.has_key?(:job_name)

    # Place each input file in-line in submit script
    n = 0
    fupload = ""
    params.keys.grep(/^.*_file_upload$/).each do |k|
      uploaded_file = params[k]
      file_content = Base64.encode64(uploaded_file.tempfile.read)
      fupload += "base64 -d > " + uploaded_file.original_filename + " << EOFinfile#{n}\n"
      fupload += file_content
      fupload += "EOFinfile#{n}\n"
      params.delete(k)
      n += 1
    end

    script = @app.exec.gsub(/\r\n/, "\n")

    script.gsub!(/%%FILES%%/, fupload)

    # Substitute out all %%KEY%% items in the job script, then assign
    params.keys.each do |k|
      script.gsub!(/%%#{k.upcase}%%/, params[k])
    end

    @job.script = script
    @job.job_owner  = User.current.login

    if params.has_key?('work_dir')
      case params['work_dir']
      when "home"
        script.gsub!(/%%WORK_DIR_PATH%%/, "$HOME/.cwa/#{@app.name}/#{@job.job_name}")
        output_uri = "\\\\" + Redmine::Cwa.output_server + "\\" + @job.job_owner + "\\.cwa\\" + @app.name + "\\" + @job.job_name
        output_uri += ";sftp://#{Redmine::Cwa.output_server}/home/#{@job.job_owner[0,1]}/#{@job.job_owner}/.cwa/#{@app.name}/#{@job.job_name}"
      when "work"
        script.gsub!(/%%WORK_DIR_PATH%%/, "$WORK/cwa/#{@app.name}/#{@job.job_name}")
        output_uri = "sftp://#{Redmine::Cwa.output_server}/work/#{@job.job_owner[0,1]}/#{@job.job_owner}/cwa/#{@app.name}/#{@job.job_name}"
      end
    else
      script.gsub!(/%%WORK_DIR_PATH%%/, "$WORK/cwa/#{@app.name}/#{@job.job_name}")
      output_uri = "sftp://#{Redmine::Cwa.output_server}/work/#{@job.job_owner[0,1]}/#{@job.job_owner}/cwa/#{@app.name}/#{@job.job_name}"
    end
        

    Rails.logger.debug "CwaJobmanager.submit() => " + @job.script

    if @job.submit
      flash[:notice] = "Submitted job"
    else
      flash[:error] = "Problem submitting job"
    end

    CwaJobHistory.create :owner => @job.job_owner, :jobid => @job.jobid, :job_name => @job.job_name, :workdir => output_uri + "/#{@job.jobid}"
      
    redirect_to :action => 'index'
  end

end
