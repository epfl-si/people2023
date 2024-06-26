# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # GET|POST /user/auth/twitter
    def oidc
      @user = User.from_omniauth(request.env["omniauth.auth"])

      if @user.persisted?
        sign_in_and_redirect @user, event: :authentication # this will throw if @user is not activated
        set_flash_message(:notice, :success, kind: "oidc") if is_navigational_format?
      else
        set_flash_message(:notice, :error, kind: "oidc") if is_navigational_format?
        redirect_to root_path
      end
    end

    def failure
      redirect_to root_path
    end

    # You should configure your model like this:
    # devise :omniauthable, omniauth_providers: [:twitter]

    # You should also create an action method in this controller like this:
    # def twitter
    # end

    # More info at:
    # https://github.com/heartcombo/devise#omniauth

    # GET|POST /resource/auth/twitter
    # def passthru
    #   super
    # end

    # GET|POST /users/auth/twitter/callback
    # def failure
    #   super
    # end

    # protected

    # The path used when OmniAuth fails
    # def after_omniauth_failure_path_for(scope)
    #   super(scope)
    # end
  end
end
