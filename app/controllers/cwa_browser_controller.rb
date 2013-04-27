class CwaBrowserController < ApplicationController
  Mime::Type.register "application/octet-stream", :plist_binary, [], ["binary.plist"]
  respond_to :plist_binary

  def index
    @project = Project.find(Redmine::Cwa.project_id)
    @user = CwaIpaUser.new
    @groups = CwaGroups.new
    @group_list = @groups.that_i_manage + @groups.member_of

    respond_to do |format|
      format.html
    end
  end

  # Change file name
  def rename
    Redmine::CwaBrowserHelper.rename(params[:file], params[:new_name]) or
      flash[:error] = "Could not rename file #{params[:file]} to #{params[:new_name]}"
    redirect_to :action => "index", :params => params
  end

  # create a directory
  def mkdir 
    if params[:new_dir] =~ /[\x00\/]/
      flash[:error] = "Invalid directory name specified!"
    else
      Redmine::CwaBrowserHelper.mkdir(params[:dir] + "/" + params[:new_dir]) or
        flash[:error] = "Could not make directory #{params[:new_dir]}"
    end
    redirect_to :action => "index", :params => params
  end

  # Create a text file
  def create
    if params[:new_file_content] != nil and params[:new_file_name] != nil
      upload = params["file"]
      file = Redmine::CwaBrowserHelper::Put.new(params[:dir], params[:new_file_name])
      if file
        file.write(params[:new_file_content])
        file.done
      else
        flash[:error] = "Could not store file(s) #{upload.original_filename}"
      end
    else
      flash[:error] = "New document name/content cannot be blank"
    end
    redirect_to :action => "index", :params => params
  end

  # Delete file/directory from :browse_path
  def delete
    Redmine::CwaBrowserHelper.delete(params[:file]) or
      flash[:error] = "Could not delete file #{params[:file]}"

    redirect_to :action => "index", :params => { :dir => params[:dir] }
  end

  # Upload file and store to :browse_path
  def upload
    upload = params["file"]
    file = Redmine::CwaBrowserHelper::Put.new(params[:dir], upload.original_filename) or
      flash[:error] = "Could not store file(s) #{upload.original_filename}"

    while (data = upload.read(1024*128)) != nil
      file.write(data)
    end

    file.done

    redirect_to :action => "index", :params => { :dir => params[:dir] }
  end

  def tail
    type = Redmine::CwaBrowserHelper.type(params[:file])
    text = ""

    if type !~ /^text\/.*/
      text = "Cannot tail file!  It is not a text file!"
    else
      file = Redmine::CwaBrowserHelper.tail(params[:file])
      Rails.logger.debug "CwaBrowserController.tail() => Im in here! #{params[:file]}"

      file.each_tail do |data|
        text += data
      end
    end

    render :text => text
  end

  # Download file from :browse_path
  def get
    self.response.headers["Content-Type"] = "application/octet-stream"
    self.response.headers["Content-Disposition"] = "attachment; filename=#{params[:file].split('/').last}"
    self.response.headers["Content-Length"] = Redmine::CwaBrowserHelper.file_size(params[:file]).to_s
    self.response.headers['Last-Modified'] = Time.now.ctime.to_s
    self.response.headers['Accept-Ranges'] = "bytes"

    self.response_body = Redmine::CwaBrowserHelper::Retrieve.new(params[:file])
  end
  
  # Download zip file archive of directory
  def get_zip
    self.response.headers["Content-Type"] = "application/octet-stream"
    self.response.headers["Content-Disposition"] = "attachment; filename=#{params[:file].split('/').last}.zip"
    self.response.headers['Last-Modified'] = Time.now.ctime.to_s
    self.response.headers['Accept-Ranges'] = "bytes"

    self.response_body = Redmine::CwaBrowserHelper::RetrieveZip.new(params[:file])
  end

end
