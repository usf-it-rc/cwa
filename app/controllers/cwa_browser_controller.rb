class CwaBrowserController < ApplicationController
  unloadable

  def index
    @project = Project.find(Redmine::Cwa.project_id)
    @user = CwaIpaUser.new

    respond_to do |format|
      format.html
    end
  end

  def test
    @project = Project.find(Redmine::Cwa.project_id)

    respond_to do |format|
      format.html
      format.json
    end
  end
end
