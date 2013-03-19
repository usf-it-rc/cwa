class CwaDbUserUtilsController < ApplicationController
  # GET /cwa_db_user_utils
  # GET /cwa_db_user_utils.json
  def index
    @cwa_db_user_utils = CwaDbUserUtil.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cwa_db_user_utils }
    end
  end

  # GET /cwa_db_user_utils/1
  # GET /cwa_db_user_utils/1.json
  def show
    @cwa_db_user_util = CwaDbUserUtil.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @cwa_db_user_util }
    end
  end

  # GET /cwa_db_user_utils/new
  # GET /cwa_db_user_utils/new.json
  def new
    @cwa_db_user_util = CwaDbUserUtil.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @cwa_db_user_util }
    end
  end

  # GET /cwa_db_user_utils/1/edit
  def edit
    @cwa_db_user_util = CwaDbUserUtil.find(params[:id])
  end

  # POST /cwa_db_user_utils
  # POST /cwa_db_user_utils.json
  def create
    @cwa_db_user_util = CwaDbUserUtil.new(params[:cwa_db_user_util])

    respond_to do |format|
      if @cwa_db_user_util.save
        format.html { redirect_to @cwa_db_user_util, notice: 'Cwa db user util was successfully created.' }
        format.json { render json: @cwa_db_user_util, status: :created, location: @cwa_db_user_util }
      else
        format.html { render action: "new" }
        format.json { render json: @cwa_db_user_util.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /cwa_db_user_utils/1
  # PUT /cwa_db_user_utils/1.json
  def update
    @cwa_db_user_util = CwaDbUserUtil.find(params[:id])

    respond_to do |format|
      if @cwa_db_user_util.update_attributes(params[:cwa_db_user_util])
        format.html { redirect_to @cwa_db_user_util, notice: 'Cwa db user util was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @cwa_db_user_util.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cwa_db_user_utils/1
  # DELETE /cwa_db_user_utils/1.json
  def destroy
    @cwa_db_user_util = CwaDbUserUtil.find(params[:id])
    @cwa_db_user_util.destroy

    respond_to do |format|
      format.html { redirect_to cwa_db_user_utils_url }
      format.json { head :no_content }
    end
  end
end
