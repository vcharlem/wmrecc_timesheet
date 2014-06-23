class RequestsController < ApplicationController
  before_action :set_request, only: [:show, :edit, :update, :destroy]
  before_action :set_requests, only: :show
  before_action :set_active_direct_reports, only: :show
  before_action :set_user
  

  def show
    @requests = set_requests
    @user = set_user
    @direct_reports_ary = set_active_direct_reports.map { |u| u.id }
    @dr_requests = Request.where( user_id: @direct_reports_ary ).sort_by { |r| r.user.lname }.sort_by &:date
    @dr_requests_unreviewed = Request.where( user_id: @direct_reports_ary ).where( sv_reviewed: false ).sort_by { |r| r.user.lname }.sort_by &:date
    @dr_requests_reviewed = Request.where( user_id: @direct_reports_ary ).where( sv_reviewed: true ).where(sv_approval: true).sort_by { |r| r.user.lname }.sort_by &:date

    @dr_review_switch = params[:review]
    @dr_cur_usr_switch = params[:cur_usr]
  end

  def new
  end

  def edit
    @request = set_request
  end

  def create
    @request = Request.new(request_params)

    respond_to do |format|
      if @request.save
        format.html { redirect_to @request, notice: 'Request was successfully created.' }
        format.json { render action: 'show', status: :created, location: @request }
      else
        format.html { render action: 'new' }
        format.json { render json: @request.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @request.update(request_params)
      flash[:success] = 'Request updated'
      redirect_to user_requests_path(params[:user_id])
    else
      render action: 'edit'
    end
  end

  def approval_flow
    @request = Request.find(params[:id])
    @approve = params[:approve]
    @reviewed = params[:reviewed]

    if @request.update_attribute(:sv_approval, @approve)
      @request.update_attribute(:sv_reviewed, @reviewed)
      # need a push to timecards
      flash[:success] = "Request updated"
      redirect_to user_requests_url(params[:user_id], cur_usr: params[:cur_usr], review: params[:review])
    else
      flash[:error] = "Something went wrong :("
      redirect_to user_requests_path(params[:user_id], cur_usr: params[:cur_usr], review: params[:review])
    end
  end

  def destroy
    @request = Request.find(params[:id])
    @request.destroy
    #need to delete associated timecard record
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_requests
      User.find(params[:user_id]).requests
    end

    def set_request
      if params[:id]
        User.find(params[:user_id]).requests.find(params[:id])
      end
    end

    def set_user
      User.find(params[:user_id])
    end

    def set_active_direct_reports
      User.where(supervisor_id: set_user.id).where(active: true)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def request_params
      params.require(:request).permit(:user_id, :date, :hours, :sv_approval, :sv_denied)
    end
end