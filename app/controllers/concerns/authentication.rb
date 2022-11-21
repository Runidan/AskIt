module Authentication
  extend ActiveSupport::Concern

  included do
    private

    def current_user
      if session[:user_id].present?
        @current_user ||= User.find_by(id: session[:user_id]).decorate if session[:user_id].present?
      elsif cookies.encrypted[:user_id].present? #если по сессии не нашли, ищем по токену
        user = User.find_by(id: cookies.encrypted[:user_id]) #находим пользователя по id из куки
        if user&.remember_token_authenticated?(cookies.encrypted[:remember_token]) #проверяем правильность токена
          @current_user ||= user.decorate
        end
      end
    end

    def user_signed_in?
      current_user.present?
    end

    def sign_in(user)
      session[:user_id] = user.id
    end

    def remember(user)
      user.remember_me #генерируем токен и записываем в таблицу
      cookies.encrypted.permanent[:remember_token] = user.remember_token #записываем токен из витруального аттрибута в куки
      cookies.encrypted.permanent[:user_id] = user.id
      # .encrypted зашифровывает куки
      #.permanent делает срок действая куки неограниченным Подробнее про куки https://api.rubyonrails.org/classes/ActionDispatch/Cookies.html
    end

    def sign_out
      session.delete :user_id
      @current_user = nil
    end

    def require_no_authentication
      return unless user_signed_in?
      flash[:warning] = "You are already signed in!"
      redirect_to root_path
    end

    def require_authentication
      return if user_signed_in?
      flash[:warning] = "You are not signed in!"
      redirect_to root_path
    end

    helper_method :current_user, :user_signed_in?
  end
end
