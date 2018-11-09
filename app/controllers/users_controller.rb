class UsersController < ApplicationController 
    before_action :set_user, only: [:edit, :update, :show, :destroy]
    before_action :require_same_user, only: [:edit, :update, :destroy]
    before_action :require_admin, only: [:destroy]
    # User.last().toggle!(admin) # to make admin easily 
    
    def index()
        @users = User.paginate(page: params[:page], per_page: 5)
    end 

    def show()
        @user_articles = @user.articles.paginate(page: params[:page], per_page: 5) 
        # doing this for pagination
    end 

    def new()
        @user = User.new()
    end
    
    def create()
        @user = User.new(user_params) 
        if(@user.save())
            session[:user_id] = @user.id # for log in 
            flash[:success] = "Welcome to the alpha blog #{@user.username}"
            redirect_to(user_path(@user))
        else
            render("new")
        end 
    end 

    def edit()
    end 

    def update()
        if(@user.update(user_params))
            flash[:success] = "Your account was updated successfully"
            redirect_to(articles_path())
        else
            render("edit")
        end   
    end 

    def destroy()
        @user.destroy
        flash[:danger] = "User and its all articles have been deleted"
        redirect_to(users_path())
    end 

    private 
        def set_user()
            @user = User.find(params[:id])
        end

        def user_params()
            params.require(:user).permit(:username, :email, :password) 
        end 

        def require_same_user()
            if(current_user != @user and !current_user.admin?()) 
                flash[:danger] = "You can only edit your own account"
                redirect_to(root_path())
            end 
        end 

        def require_admin()
            if(logged_in? and !(current_user().admin?()))
                flash[:danger] = "Only admin users can perform this action"
                redirect_to(root_path())
            end
        end 
end 