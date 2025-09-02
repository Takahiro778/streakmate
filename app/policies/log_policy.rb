class LogPolicy < ApplicationPolicy
  # /logs#index は policy_scope を使う想定（verify_policy_scoped 推奨）

  def show?
    record.visible_to?(user)
  end

  def create?
    record.owned_by?(user)
  end

  def update?
    record.owned_by?(user)
  end

  def destroy?
    record.owned_by?(user)
  end

  class Scope < Scope
    def resolve
      # 未ログイン: 公開のみ
      return scope.where(visibility: Log.visibilities[:public]) if user.nil?

      # ログイン時: 公開 or 自分 or フォロワー限定(フォロー先)
      follows_subq = Follow.where(follower_id: user.id).select(:followed_id)

      pub  = scope.where(visibility: Log.visibilities[:public])
      mine = scope.where(user_id: user.id)
      foll = scope.where(visibility: Log.visibilities[:followers], user_id: follows_subq)

      pub.or(mine).or(foll)
    end
  end
end
