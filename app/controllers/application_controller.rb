# frozen_string_literal: true

# 各コントローラーの基底クラスとして動作します。
class ApplicationController < ActionController::Base
  include SessionsHelper
  def hello
    render html: 'hello, world!'
  end
end
