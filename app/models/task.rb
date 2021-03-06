class Task < ActiveRecord::Base
  belongs_to :package
  belongs_to :type
  belongs_to :status
  attr_accessible :package_id, :type_id, :status_id
  before_create :set_type_and_status
  after_create :check_package
  before_update :check_status
  after_commit :enqueue_remote_job
  validates :package_id, uniqueness: {scope: :type_id,
    message: "should be unique for a given type"
  }
  has_paper_trail

  delegate :batch, to: :package

  scope :in_progress, :conditions => [
    Status.ready,
    Status.not_ready,
    Status.started,
    Status.completed,
    Status.failed,
  ].map { |s| "status_id = #{s.id}" }.join(' OR ')

  def notify message
    if message
      method = "when_#{message.to_s.gsub(/\s+/, '_')}".to_sym
      if respond_to? method
        logger.debug "\nDEBUG task #{self.id}: dispatching to #{method}"
        send(method)
      else
        logger.debug "\nDEBUG task #{self.id}: can't dispatch to #{method}"
      end
    end
  end

  def ready?
    if [Status.ready, Status.not_ready].include? self.status
      case self.type

      when Type.create_dip
        self.package.local_aip_fixed?

      when Type.store_test_dip
        self.package.local_dip_fixed? or self.package.dark_archive?

      when Type.store_test_oral_history_files
        self.package.remote_test_dip_fixed? or self.package.dark_archive?

      when Type.store_oral_history_files
        self.package.remote_dip_fixed? or self.package.dark_archive?

      when Type.store_logs
        self.package.remote_aip_fixed?

      else
        true
      end
    else
      true
    end
  end

  def set_readiness
    determine_readiness
    self.save
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
      determine_readiness
      if self.status == Status.completed
        create_next_task
      end
    end
  end

  def determine_readiness
    if [Status.ready, Status.not_ready].include? self.status
      if self.ready?
        self.status = Status.ready
      else
        self.status = Status.not_ready
      end
    end
  end

  def create_next_task
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

  def check_package
    if self.type == Type.approve_package
      package = Package.find(self.package_id)
      package.update_attributes(:status_id => Status.awaiting_approval.id)
    end
  end

  def enqueue_remote_job
    if self.status == Status.ready and not(self.destroyed?)
      package = Package.find(self.package_id)
      batch = Batch.find(package.batch_id)
      server = Server.find(batch.server_id)
      type = Type.find(self.type_id)
      Resque.enqueue(LaunchRemoteJob, {server: server, package: package, task: self, type: type})
    end
  end

  def to_s
    "#{self.id} (#{self.type.name} - #{self.package.name} - #{self.batch.server.name})"
  end
end
