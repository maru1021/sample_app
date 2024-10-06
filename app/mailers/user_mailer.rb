# frozen_string_literal: true

class UserMailer < ApplicationMailer
  # http://localhost:3000/rails/mailers/user_mailer/account_activation.txt?locale=en
  def account_activation(user)
    @user = user
    mail to: user.email, subject: 'Account activation'
  end

  def password_reset
    @greeting = 'Hi'

    mail to: 'to@example.org'
  end
end
