class MemberTimesController < ApplicationController
  # GET /member_times
  # GET /member_times.json
  def index
    @member_times = MemberTime.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @member_times }
    end
  end

  # GET /member_times/1
  # GET /member_times/1.json
  def show
    @member_time = MemberTime.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @member_time }
    end
  end

  # GET /member_times/new
  # GET /member_times/new.json
  def new
    @member_time = MemberTime.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @member_time }
    end
  end

  # GET /member_times/1/edit
  def edit
    @member_time = MemberTime.find(params[:id])
  end

  # POST /member_times
  # POST /member_times.json
  def create
    @member_time = MemberTime.new(params[:member_time])

    respond_to do |format|
      if @member_time.save
        format.html { redirect_to @member_time, notice: 'Member time was successfully created.' }
        format.json { render json: @member_time, status: :created, location: @member_time }
      else
        format.html { render action: "new" }
        format.json { render json: @member_time.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /member_times/1
  # PUT /member_times/1.json
  def update
    @member_time = MemberTime.find(params[:id])

    respond_to do |format|
      if @member_time.update_attributes(params[:member_time])
        format.html { redirect_to @member_time, notice: 'Member time was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @member_time.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /member_times/1
  # DELETE /member_times/1.json
  def destroy
    @member_time = MemberTime.find(params[:id])
    @member_time.destroy

    respond_to do |format|
      format.html { redirect_to member_times_url }
      format.json { head :no_content }
    end
  end
end
