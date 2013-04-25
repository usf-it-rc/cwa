class CwaBrowserController < ApplicationController
  Mime::Type.register "application/octet-stream", :plist_binary, [], ["binary.plist"]
  respond_to :plist_binary

  def index
    @project = Project.find(Redmine::Cwa.project_id)
    @user = CwaIpaUser.new

    respond_to do |format|
      format.html
    end
  end

  # Change file mode, name
  def post
    case params[:browser_method]
    when "chmod"
      Redmine::CwaBrowserHelper.chmod(params[:browser_file], params[:mode]) or
        flash[:error] = "Could not set mode on file #{params[:browser_file]}"
    when "rename"
      Redmine::CwaBrowserHelper.rename(params[:browser_file], params[:new_name]) or
        flash[:error] = "Could not rename file #{params[:browser_file]} to #{params[:new_name]}"
    end
    redirect_to :action => "index", :params => params[:browser_dir]
  end

  # Delete file/directory from :browse_path
  def delete
    Redmine::CwaBrowserHelper.delete(params[:browser_file]) or
      flash[:error] = "Could not delete file #{params[:browser_file]}"
    redirect_to :action => "index", :params => params[:browser_dir]
  end

  # Upload file and store to :browse_path
  def put
    Redmine::CwaBrowserHelper.write(params[:browser_dir], params[:upload_file]) or
      flash[:error] = "Could not store file(s) #{params[:upload_file]}"
    redirect_to :action => "index", :params => params[:browser_dir]
  end

  # Download file from :browse_path
  def get
    offset = 0
    bytes_left = 1
    data = 1

    self.response.headers["Content-Type"] = "application/octet-stream"
    self.response.headers["Content-Disposition"] = "attachment; filename=#{params[:browser_file].split('/').last}"
    self.response.headers["Content-Length"] = Redmine::CwaBrowserHelper.file_size(params[:browser_file]).to_s
    self.response.headers['Last-Modified'] = Time.now.ctime.to_s
    self.response.headers['Accept-Ranges'] = "bytes"

    self.response_body = Redmine::CwaBrowserHelper::Retrieve.new(params[:browser_file])
  end

end
