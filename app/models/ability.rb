class Ability
  include CanCan::Ability

  def initialize(user)
    if user.role? :admin
      can :manage, :all
    else
      can :read, :all
      if user.role? :approver
        can :approve, Package
        can :reject, Package
      end
    end
  end
end
