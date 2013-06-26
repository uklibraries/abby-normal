class Task < ActiveRecord::Base
  belongs_to :package
  belongs_to :type
  belongs_to :status
  attr_accessible :package_id, :type_id, :status_id
  before_create :set_type_and_status
  before_update :check_status

  def ready?
    # We only block status progression at the
    # ready/not ready stage.  Once an item has
    # started, it will either complete or fail
    # but not otherwise be blocked.
    if [Status.ready, Status.not_ready].include? self.status
      true
#      case self.type
#
#      # TO BE ADDED
#
#      # No other task types have prerequisites
#      # beyond completion of the prior task
#      else
#        true
#      end
    else
      true
    end
  end

  private
  
  def set_type_and_status
    self.type ||= Type.find(1)
    self.status ||= Status.ready
    unless self.ready?
      self.status = Status.not_ready
    end
  end

  def check_status
    if self.status_id_changed?
      method = "when_#{self.status.name}".to_sym
      begin
        logger.debug "\n#{method}"
        send(method)
      rescue
        logger.debug "\ncan't dispatch to #{method}"
      end
    end
  end

  def when_ready
    unless self.ready?
      self.status = Status.not_ready
    end
  end

  def when_completed
    package = Package.find(self.package_id)
    type = Type.where(:id => self.type_id + 1).first
    if type
      package.tasks.create(:type_id => type.id)
    else
      package.status = Status.completed
      package.save
    end
    self.status = Status.archived
  end

  def when_failed
    package = Package.find(self.package_id)
    package.status = Status.failed
    package.save
  end
end
