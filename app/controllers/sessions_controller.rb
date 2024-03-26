class SessionsController < ApplicationController

    def destroy
        #super
        session[:user_id] = nil
        current_user = nil
        flash[:success] = "Logged out"
        
        #debugger
        redirect_to root_path
      end
end