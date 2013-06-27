class Package < ActiveRecord::Base
  belongs_to :batch
  belongs_to :status
  has_many :tasks, dependent: :destroy
  attr_accessible :aip_identifier, :approved, :dark_archive, :dip_identifier, :oral_history, :sip_path, :batch_id, :status_id, :requires_approval
  before_create :mark_as_started
  after_create :create_first_task
  after_update :check_task_statuses

  private

  def mark_as_started
    self.status ||= Status.started
  end

  def create_first_task
    self.tasks.create
  end

  def check_task_statuses
    self.tasks.where(:status_id => Status.ready.id).each do |task|
      unless task.ready?
        task.status = Status.not_ready
        task.save
      end
    end
    self.tasks.where(:status_id => Status.not_ready.id).each do |task|
      if task.ready?
        task.status = Status.ready
        task.save
      end
    end
  end

  def when_failed
    package = Package.find(self.package_id)
    package.status = Status.failed
    package.save
  end
end
