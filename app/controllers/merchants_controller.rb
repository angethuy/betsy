class MerchantsController < ApplicationController

  def show
    @merchant = Merchant.find(params[:id])

    if @merchant.nil?
      head :not_found
      return
    end
  end


  def create
    auth_hash = request.env["omniauth.auth"]

    merchant = Merchant.find_by(uid: auth_hash[:uid], provider: "github")
    if merchant
      # User was found in the database
      flash[:success] = "Logged in as returning user #{merchant.username}"
    else
      # User doesn't match anything in the DB
      # Attempt to create a new user
      merchant = Merchant.build_from_github(auth_hash)

      if merchant.save
        flash[:success] = "Logged in as new merchant #{merchant.username}"
      else
        # Couldn't save the user for some reason. If we
        # hit this it probably means there's a bug with the
        # way we've configured GitHub. Our strategy will
        # be to display error messages to make future
        # debugging easier.
        flash[:error] = "Could not create new user account: #{merchant.errors.messages}"
        return redirect_to root_path
      end
    end

    # If we get here, we have a valid user instance
    session[:merchant_id] = merchant.id
    return redirect_to root_path
  end

  # def current
  #   unless @current_user
  #     flash[:error] = "You must be logged in to see this page"
  #     redirect_to root_path
  #     return
  #   end
  # end

  # def destroy
  #   session[:user_id] = nil
  #   flash[:success] = "Successfully logged out!"

  #   redirect_to root_path
  # end


end