class UpController < ActionController::API
  def show
    # DB も確認したい場合は次の 2 行をコメント解除
    # ActiveRecord::Base.connection.execute("SELECT 1")
    # head :ok and return

    render plain: "ok", status: :ok
  end
end
