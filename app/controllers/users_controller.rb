class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(users_params)
    if @user.save
      flash[:success] = "Account registered!"
      redirect_to root_path
    else
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  private

  def users_params
    params.require(:user).permit(:email, :companyname, :phone, :escalationlevel, :password, :password_confirmation)
  end
end