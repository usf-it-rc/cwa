class CwaDbGrpUtilsController < ApplicationController
  # GET /cwa_db_grp_utils
  # GET /cwa_db_grp_utils.json
  def index
    @cwa_db_grp_utils = CwaDbGrpUtil.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cwa_db_grp_utils }
    end
  end

  # GET /cwa_db_grp_utils/1
  # GET /cwa_db_grp_utils/1.json
  def show
    @cwa_db_grp_util = CwaDbGrpUtil.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @cwa_db_grp_util }
    end
  end

  # GET /cwa_db_grp_utils/new
  # GET /cwa_db_grp_utils/new.json
  def new
    @cwa_db_grp_util = CwaDbGrpUtil.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @cwa_db_grp_util }
    end
  end

  # GET /cwa_db_grp_utils/1/edit
  def edit
    @cwa_db_grp_util = CwaDbGrpUtil.find(params[:id])
  end

  # POST /cwa_db_grp_utils
  # POST /cwa_db_grp_utils.json
  def create
    @cwa_db_grp_util = CwaDbGrpUtil.new(params[:cwa_db_grp_util])

    respond_to do |format|
      if @cwa_db_grp_util.save
        format.html { redirect_to @cwa_db_grp_util, notice: 'Cwa db grp util was successfully created.' }
        format.json { render json: @cwa_db_grp_util, status: :created, location: @cwa_db_grp_util }
      else
        format.html { render action: "new" }
        format.json { render json: @cwa_db_grp_util.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /cwa_db_grp_utils/1
  # PUT /cwa_db_grp_utils/1.json
  def update
    @cwa_db_grp_util = CwaDbGrpUtil.find(params[:id])

    respond_to do |format|
      if @cwa_db_grp_util.update_attributes(params[:cwa_db_grp_util])
        format.html { redirect_to @cwa_db_grp_util, notice: 'Cwa db grp util was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @cwa_db_grp_util.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cwa_db_grp_utils/1
  # DELETE /cwa_db_grp_utils/1.json
  def destroy
    @cwa_db_grp_util = CwaDbGrpUtil.find(params[:id])
    @cwa_db_grp_util.destroy

    respond_to do |format|
      format.html { redirect_to cwa_db_grp_utils_url }
      format.json { head :no_content }
    end
  end
end
