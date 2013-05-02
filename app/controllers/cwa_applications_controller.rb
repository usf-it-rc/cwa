require 'rsgejob'

class CwaApplicationsController < ApplicationController
  unloadable

  def new
    @app = CwaApplication.new
    @project = Project.find(params[:project_id])

    render :action => 'show', :project_id => params[:project_id]
  end

  def show
    @user = CwaIpaUser.new
    (redirect_to :controller => 'cwa_default', :action => 'not_activated' and return) if !@user.provisioned?
    @project = Project.find(params[:project_id])
    @app = CwaApplication.find(params[:id])
    Rails.logger.debug "Apps::Show => #{@app.to_s}"
    respond_to do |format|
      format.html
    end
  end

  def update
    if CwaApplication.update(params[:id], params[:cwa_application])
      flash[:notice] = "Application successfully defined!"
    else
      flash[:error] = "Problem adding application!"
    end
    redirect_to :action => 'index', :project_id => params[:project_id]
  end

  def new
    @project = Project.find(params[:project_id])

    if params[:cwa_application].nil?
      @app = CwaApplication.new
      render :action => 'show', :project_id => params[:project_id]
      return 
    else
      app = CwaApplication.create(params[:cwa_application])
      if app.valid?
        flash[:notice] = "Application successfully defined!"
      else
        flash[:error] = "Problem adding application!"
        app.errors.keys.each do |attrib|
          app.errors[attrib].each do |str|
            flash[:error] += " #{attrib.to_s} " + str
          end
        end
      end
      redirect_to :action => 'index', :project_id => params[:project_id]
      return
    end
  end

  def delete
    @app = CwaApplication.find(params[:id])
    if @app.destroy
      flash[:notice] = "Successfully deleted application!"
    else 
      flash[:error] = "Problem deleting application!"
    end
    redirect_to :action => 'index', :project_id => params[:project_id]
  end

  def index
    @user = CwaIpaUser.new
    (redirect_to :controller => 'cwa_default', :action => 'not_activated' and return) if !@user.provisioned?
    @project = Project.find(params[:project_id])
    @apps = CwaApplication.find_all_by_project_id(@project.id).sort_by &:name

    respond_to do |format|
      format.html
    end
  end

  def display
    @user = CwaIpaUser.new
    (redirect_to :controller => 'cwa_default', :action => 'not_activated' and return) if !@user.provisioned?
    @project = Project.find(params[:project_id])
    @app = CwaApplication.find(params[:id])
    @job = RsgeJob.new
    @times = Array.new
    @browser = nil

    if params[:dir] == nil and params[:selected_dir] != nil
      params.merge!({ :dir => params[:selected_dir] })
    end

    if params[:dir] != nil
      begin 
        @browser = CwaBrowser.new params[:dir]
      rescue Exception => e
        flash[:error] = e.message
        @browser = CwaBrowser.new @user.homedirectory
        redirect_to :action => 'display', :dir => @user.homedirectory, :project_id => params[:project_id]
        return
      end
    else
      @browser = CwaBrowser.new @user.homedirectory
    end 

    (1..168).to_a.each { |t| @times << t.to_s + ":00:00" }

    # Render haml from the database, include nice header
    haml = <<EOF
= stylesheet_link_tag "/plugin_assets/cwa/stylesheets/appmanager.css"
%h2 Run #{@app.name} v#{@app.version}
#{@app.haml_form}
EOF
    render :inline => haml, :type => 'haml', :layout => true
  end

end
