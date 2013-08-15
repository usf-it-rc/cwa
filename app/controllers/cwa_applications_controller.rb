require 'rsgejob'

class CwaApplicationsController < ApplicationController
  unloadable
  include CwaIpaAuthorize

  before_filter :find_project, :authorize, :ipa_authorize

  def new
    @app = CwaApplication.new
    render :action => 'show', :project_id => params[:project_id]
  end

  def show
    @app = CwaApplication.find(params[:id])
    Rails.logger.debug "Apps::Show => #{@app.to_s}"
    respond_to do |format|
      format.html
    end
  end

  def update
    # Look for CamelCase declarations and squash them
    haml_form = params[:cwa_application][:haml_form]
    if haml_form =~ /\=\W*[A-Z]([A-Z0-9]*[a-z][a-z0-9]*[A-Z]|[a-z0-9]*[A-Z][A-Z0-9]*[a-z])[A-Za-z0-9]\.*/
      flash[:error] = "Parse error: Do not instantiate or attempt to use outside classes (CamelCase)"
      @app = CwaApplication.find(params[:id])
      render :action => 'show', :params => params
      return
    end
      
    if CwaApplication.update(params[:id], params[:cwa_application])
      flash[:notice] = "Application successfully defined!"
    else
      flash[:error] = "Problem adding application!"
    end
    redirect_to :action => 'index', :project_id => params[:project_id]
  end

  def new
    if params[:cwa_application].nil?
      @app = CwaApplication.new
      render :action => 'show', :project_id => params[:project_id]
      return 
    else
      haml_form = params[:cwa_application][:haml_form]
      if haml_form =~ /\=\W*[A-Z]([A-Z0-9]*[a-z][a-z0-9]*[A-Z]|[a-z0-9]*[A-Z][A-Z0-9]*[a-z])[A-Za-z0-9]\.*/
        flash[:error] = "Parse error: Do not instantiate or attempt to use outside classes (CamelCase)"
        @app = CwaApplication.new(params[:cwa_application])
        render :action => 'show', :params => params
        return
      end
      
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
    @apps = CwaApplication.find_all_by_project_id(@project.id).sort_by &:name

    respond_to do |format|
      format.html
    end
  end

  def display
    @app = CwaApplication.find(params[:id])
    grp = CwaGroups.new
    @job = RsgeJob.new
    @times = Array.new
    @browser = nil
    @groups = Array.new

    if params[:dir] == nil and params[:selected_dir] != nil
      params.merge!({ :dir => params[:selected_dir] })
    end

    begin 
      @browser = CwaBrowser.new params[:share], params[:dir]
    rescue Exception => e
      flash[:error] = e.message
      redirect_to :action => 'display', :project_id => params[:project_id]
      return
    end

    (1..168).to_a.each { |t| @times << t.to_s + ":00:00" }

    (grp.that_i_manage + grp.member_of).each {|g| @groups << g[:cn]}

    # View will render haml from the model
    @haml = @app.haml_form

    respond_to do |format|
      format.html
    end
  end

  private
  def find_project
    @project = Project.find(params[:project_id])
  end

end
