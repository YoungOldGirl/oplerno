# Maintains the #Cart, each #Cart is tied to only one user. And once paid
# for it is transfered to Instructure.
#
# Links to #Courses using #CartsCourses
class CartsController < InheritedResources::Base
  before_filter :set_cart, only: [:create, :show, :edit, :update, :destroy]
  before_filter :authenticate_user!

  helper_method :remove_course_from_cart_url,
    :remove_course_from_cart,
    :logged_in?

  def index
    redirect_to '/carts/mycart'
  end

  def create
    p params
    session[:course_id] = params[:course] unless params[:course].nil?
    course = Course.find(session[:course_id])
    add_to_cart course
    @cart.save

    session[:course_id] = nil
    redirect_to courses_url
  end

  def show
    respond_to do |format|
      format.json { render json: @cart.courses, status: :ok }
      format.html { render action: 'show' }
    end
  end

  def destroy
    @cart.courses.clear
    @cart.destroy

    redirect_to courses_url
  end

  def remove_course_from_cart_url(course)
    "/carts/#{Cart.find_by_user_id(@user.id).id}/#{course.id}"
  end

  def remove_course_from_cart
    @cart = Cart.find(params[:cart])
    course = Course.find(params[:course])
    @cart.courses.delete(course)
    flash[:notice] = (I18n.t 'cart.removed', {course: course.name})
    redirect_to "/carts/#{@cart.id}"
  end

  private

  def add_to_cart(course)
    if course.price.to_i > 0
      unless @user.courses.include?(course)
        add_course_to_cart(course)
      else
        flash[:alert] = (I18n.t 'courses.fail.already_in')
      end
    else
      flash[:alert] = (I18n.t 'courses.fail.inactive')
    end
  end

  def add_course_to_cart(course)
    if course.users.count < course.max
      @cart.courses << course unless @cart.courses.include?(course)
      flash[:notice] = (I18n.t 'courses.success.add_to_cart')
    else
      flash[:alert] = (I18n.t 'courses.fail.too_many')
    end
  end

  def set_cart
    set_user
    unless @user.cart.nil?
      @cart = Cart.find_by_user_id(@user.id)
    else
      @cart = @user.build_cart
    end
  end

  def cart_params
    params[:cart]
  end

  def set_user
    @user = if current_user.nil?
              create_and_signin_user
            else
              current_user
            end
  end

  def create_and_signin_user
    user = create_user
    cart_sign_in user
    user
  end

  def create_user
    user = User.new
    user.password = generated_code
    user.password_confirmation = generated_code
    user.confirm!
    user.email = "#{generated_code}@localhost"
    user.save!
    user
  end

  def cart_sign_in user
    sign_in :user, user
  end

  def generated_code
    token ||= Digest::SHA256.hexdigest(Time.now.to_s)[0..10]
  end
end
