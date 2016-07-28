class RelationshipsController < ApplicationController
  before_action :logged_in_user
  def index
    @user = User.find_by id: params[:user_id]
    if params[:type] == "following"
      @title = "Following"
      @users = @user.following.paginate page: params[:page]
    else
      @title = "Follower"
      @users = @user.followers.paginate page: params[:page]
    end
  end

  def create
    @user = User.find_by id: params[:followed_id]
    current_user.follow @user
    @relationship = current_user.active_relationships.build

    respond_to do |format|
      format.html {redirect_to @user}
      format.js
    end
  end

  def destroy
    @relationship = Relationship.find_by id: params[:id]
    @user = @relationship.followed
    current_user.unfollow @user
    @relationship =
      current_user.active_relationships.find_by followed_id: @user.id

    respond_to do |format|
      format.html {redirect_to @user}
      format.js
    end
  end

end
