class CwaGroupmanagerController < ApplicationController
  unloadable

  def index
   respond_to do |format|
      format.html
    end
  end

end
