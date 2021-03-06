class ParkItsController < ApplicationController
	before_action :set_spot, only: :create
	before_action :set_park_it, only: :update

	def create
		@park_it = ParkIt.new(park_it_params) #passed kind and time
    @park_it.user = current_user #assign user
    @park_it.spot = @spot #assign spot
    @park_it.save!
    current_user.points += @park_it.points #update current user with points
    current_user.save!
    @spot.update!(status: "taken")
    flash[:notice] = "+ 100 points for you!"
	end

  def update
    @park_it.update!(park_it_params)
    if @park_it.kind == "update"
      @park_it.update!(points: 100)
      flash[:notice] = "+ 100 points for updating your time!"
    else # kind is leave
      @park_it.update!(points: calc_points(@park_it.paid_until))
      @park_it.spot.update!(status: "avail") #change spot status as function of parkiit kind
      flash[:notice] = "+ #{@park_it.points} points for leaving!"
    end
    current_user.points += @park_it.points #update current user with points
    current_user.save!
	end

	private

	def park_it_params
    params.require(:park_it).permit(:kind, :paid_until, :points)
  end

  def set_spot
    @spot = Spot.find(params[:spot_id])
  end

  def set_park_it
    @park_it = ParkIt.find(params[:id])
  end

	def calc_points(time)
    if time.nil?
      return 100
		elsif (time - Time.now)/60 > 120 # if expiration time is more than 120 minutes (2 hours) from now
			return 800
		elsif (time - Time.now)/60 < 30 # if expiration time is less than 30 min
			return 200
		else # time left is somewhere between 30 minutes and 3 hours
			return 400
		end
	end

end
