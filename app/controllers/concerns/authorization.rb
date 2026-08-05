module Authorization
  extend ActiveSupport::Concern

  private

  def require_member!
    unless current_user&.at_least_member?
      redirect_to root_path, alert: t("authorization.member_required")
    end
  end

  def require_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: t("authorization.admin_required")
    end
  end
end
