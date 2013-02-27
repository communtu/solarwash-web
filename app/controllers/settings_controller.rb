class SettingsController < ApplicationController
  before_filter :authenticate_admin_user!
  
  # GET /Settings
  # GET /Settings.json
  def index
    @settings = Setting.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @settings }
    end
  end

  # GET /Settings/1
  # GET /Settings/1.json
  def show
    @setting = Setting.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @setting }
    end
  end

  # GET /Settings/new
  # GET /Settings/new.json
  def new
    @setting = Setting.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @setting }
    end
  end

  # GET /Settings/1/edit
  def edit
    @setting = Setting.find(params[:id])
  end

  # POST /Settings
  # POST /Settings.json
  def create
    @setting = Setting.new(params[:Setting])

    respond_to do |format|
      if @setting.save
        format.html { redirect_to @setting, notice: 'Settingm wurde erfolgreich angelegt.' }
        format.json { render json: @setting, status: :created, location: @setting }
      else
        format.html { render action: "new" }
        format.json { render json: @setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /Settings/1
  # PUT /Settings/1.json
  def update
    @setting = Setting.find(params[:id])

    respond_to do |format|
      if @setting.update_attributes(params[:Setting])
        format.html { redirect_to @setting, notice: 'Setting wurde erfolgreich geaendert.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /Settings/1
  # DELETE /Settings/1.json
  def destroy
    @setting = Setting.find(params[:id])
    @setting.destroy

    respond_to do |format|
      format.html { redirect_to Settings_url }
      format.json { head :no_content }
    end
  end
end
