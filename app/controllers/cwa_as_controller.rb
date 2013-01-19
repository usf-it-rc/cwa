class CwaAsController < ApplicationController
  unloadable

  def index
    @plugin = CwaAs.new

    respond_to do |format|
      format.html
    end
  end

  def success
  end

  def create
    flash[:notice] = 'Successfully registered'
    redirect_to :action => 'index'
  end

  def failure
    flash[:error] = 'Account registered'
    redirect_to :action => 'index'
  end

  def delete
  end

end
