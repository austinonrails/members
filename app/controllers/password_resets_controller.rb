class PasswordResetsController < ApplicationController  
  before_filter :load_member_using_perishable_token, :only => [:edit, :update]  
  before_filter :require_no_member

  def create  
    @member = Member.find_by_email(params[:email])  
    
    if @member  
      flash[:notice] = "Instructions to reset your password have been emailed to you. " +  
      "Please check your email."  
      redirect_to root_url  
    else  
      flash[:notice] = "No member was found with that email address"  
      render :action => :new  
    end  
  end

  def update  
    @member.password = params[:member][:password]  
    @member.password_confirmation = params[:member][:password_confirmation]  
    if @member.save  
      flash[:notice] = "Password successfully updated"  
      redirect_to root_url  
    else  
      render :action => :edit  
    end  
  end
  
  private  
  def load_member_using_perishable_token  
    @member = Member.find_using_perishable_token(params[:id])  
    unless @member  
      flash[:notice] = "We're sorry, but we could not locate your account. " +  
                       "If you are having issues try copying and pasting the URL " +  
                       "from your email into your browser or restarting the " +  
                       "reset password process."  
      redirect_to root_url  
    end  
  end
end