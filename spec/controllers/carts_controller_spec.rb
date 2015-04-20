require 'spec_helper'

describe CartsController do
  let(:valid_cart) { {} }

  let(:valid_course) { {name: 'The Orange Theme', price: '1'} }

  context 'Not Logged In' do
    before(:each) do
      course = Course.create! valid_course
      session[:course_id] = course.id
    end

    describe 'POST create' do
      describe 'with valid params' do
        it 'creates a new Cart' do
          expect {
            post :create, {:cart => valid_cart}
          }.to change(Cart, :count).by(1)
        end

        it 'assigns a newly created cart as @cart' do
          post :create, {:cart => valid_cart}
          assigns(:cart).should be_a(Cart)
          assigns(:cart).should be_persisted
        end

        it 'should add the course to the cart' do
          @course = Course.create! valid_course

          def valid_session
            mysession = { course_id: @course.id }
            session.to_hash.merge mysession
          end

          post :create, {}, valid_session

          expect(session[:course_id]).to eq nil
        end

        it 'can add the course to the cart twice' do
          @course = Course.create! valid_course

          def valid_session
            mysession = { course_id: @course.id }
            session.to_hash.merge mysession
          end

          post :create, {}, valid_session
          session[:course_id].should be(nil)
          flash[:notice].should eq (I18n.t 'courses.success.add_to_cart')
          flash[:alert].should be nil

          post :create, {}, valid_session
          session[:course_id].should be(nil)
          flash[:notice].should eq (I18n.t 'courses.success.add_to_cart')
          flash[:alert].should be nil
        end

        it 'can\'t add the course to the cart if the class is full' do
          @course = Course.create! valid_course
          @course.max = 0
          @course.save

          def valid_session
            mysession = { course_id: @course.id }
            session.to_hash.merge mysession
          end

          post :create, {}, valid_session
          flash[:notice].should be nil
          flash[:alert].should eq (I18n.t 'courses.fail.too_many')
        end
      end
    end
  end

  context 'Logged In' do
    login_user

    before(:each) do
      course = Course.create! valid_course
      session[:course_id] = course.id
    end

    before do
      @cart = Cart.create! valid_cart
      @cart.user = current_user
      @cart.save
    end

    after do
      @cart.destroy
    end

    describe 'GET show' do
      it 'assigns the requested cart as @cart' do
        get :show, {:id => @cart.to_param}
        assigns(:cart).should eq(@cart)
      end
    end

    describe 'POST create' do
      before do
        @cart.destroy
      end

      describe 'with valid params' do
        it 'creates a new Cart' do
          expect {
            post :create, {:cart => valid_cart}
          }.to change(Cart, :count).by(1)
        end

        it 'assigns a newly created cart as @cart' do
          post :create, {:cart => valid_cart}
          assigns(:cart).should be_a(Cart)
          assigns(:cart).should be_persisted
        end

        it 'should add the course to the cart' do
          @course = Course.create! valid_course

          def valid_session
            mysession = { course_id: @course.id }
            session.to_hash.merge mysession
          end

          post :create, {}, valid_session

          session[:course_id].should be(nil)
        end

        it 'can add the course to the cart twice' do
          @course = Course.create! valid_course

          def valid_session
            mysession = { course_id: @course.id }
            session.to_hash.merge mysession
          end

          post :create, {}, valid_session
          session[:course_id].should be(nil)
          flash[:notice].should eq (I18n.t 'courses.success.add_to_cart')
          flash[:alert].should be nil

          post :create, {}, valid_session
          session[:course_id].should be(nil)
          flash[:notice].should eq (I18n.t 'courses.success.add_to_cart')
          flash[:alert].should be nil
        end

        it 'can\'t add the course to the cart if you are taking it' do
          @course = Course.create! valid_course

          def valid_session
            mysession = { course_id: @course.id }
            session.to_hash.merge mysession
          end

          current_user.courses << @course

          post :create, {}, valid_session
          flash[:notice].should be nil
          flash[:alert].should eq (I18n.t 'courses.fail.already_in')
        end

        it 'can\'t add the course to the cart if the class is full' do
          @course = Course.create! valid_course
          @course.max = 0
          @course.save

          def valid_session
            mysession = { course_id: @course.id }
            session.to_hash.merge mysession
          end

          post :create, {}, valid_session
          flash[:notice].should be nil
          flash[:alert].should eq (I18n.t 'courses.fail.too_many')
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved cart as @cart' do
          # Trigger the behavior that occurs when invalid params are submitted
          Cart.any_instance.stub(:save).and_return(false)
          post :create, {:cart => {}}
          assigns(:cart).should be_a(Cart)
        end
      end
    end

    describe 'DELETE destroy' do
      it 'destroys the requested cart' do
        expect {
          delete :destroy, {:id => @cart.to_param}
        }.to change(Cart, :count).by(-1)
      end

      it 'redirects to the carts list' do
        delete :destroy, {:id => @cart.to_param}
        response.should redirect_to(courses_url)
      end
    end

    describe 'post Remove from cart' do
      it 'remove' do
        course = @cart.courses.create! valid_course
        expect {
          post :remove_course_from_cart, {cart: @cart.id, course: course.id}
        }.to change(@cart.courses, :count).by(-1)
        response.should redirect_to(@cart)
        flash[:notice].should eq (I18n.t 'cart.removed', {course: course.name})
      end
    end
  end
end
