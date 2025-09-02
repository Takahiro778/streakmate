class LogPolicy < ApplicationPolicy
  # /logs#index 用は authorize を掛けず policy_scope を使う前提なので
  # index? は不要（verify_policy_scoped を付ければOK）

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
      # モデル側に用意した統一入口を利用（推奨）
      scope.policy_scope_for(user)
      # ↑を用意していない場合は ↓でもOK
      # user.nil? ? scope.visibility_public : scope.visible_to(user)
    end
  end
end
