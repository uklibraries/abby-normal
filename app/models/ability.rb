class Ability
  include CanCan::Ability

  def initialize(user)
    if user.role? :admin
      can :manage, :all
    else
      can :read, :all
      if user.role? :approver
        #can :create, Approval
      end
    end
  end
end