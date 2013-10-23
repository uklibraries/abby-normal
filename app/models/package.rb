class Package < ActiveRecord::Base
  belongs_to :batch
  belongs_to :status
  has_many :tasks, dependent: :destroy
  attr_accessible :aip_identifier, :approved, :batch_id, :dark_archive, :dip_identifier, :oral_history, :reprocessing, :requires_approval, :sip_path, :status_id
  before_create :mark_as_started
  after_create :maybe_create_first_task
  before_update :check_status
  after_update :check_task_statuses
  after_save :ping_batch
  has_paper_trail

  scope :in_progress, :conditions => [
    Status.approved,
    Status.rejected,
    Status.awaiting_approval,
    Status.under_review,
    Status.started,
  ].map { |s| "status_id = #{s.id}" }.join(' OR ')

  def name
    File.basename self.sip_path
  end

  def notify message
    if message
      method = "when_#{message.to_s.gsub(/\s+/, '_')}".to_sym
      if respond_to? method
        logger.debug "\nDEBUG package #{self.id}: dispatching to #{method}"
        send(method)
      else
        logger.debug "\nDEBUG package #{self.id}: can't dispatch to #{method}"
      end
    end
  end

  private

  def mark_as_started
    self.status ||= Status.started
  end

  def maybe_create_first_task
    unless self.reprocessing?
      self.tasks.create
    end
  end

  def check_status
    if self.status_id_changed?
      batch = Batch.find(self.batch_id)
      case self.status
      when Status.awaiting_approval
        if batch.status == Status.started
          batch.update_attributes(:status_id => Status.awaiting_approval.id)
        end
      when Status.approved
        self.approved = true
        complete_approve_package_task
        batch.mark_reviewed
      when Status.rejected
        batch.mark_reviewed
      end
    end 
  end

  def ping_batch
    if self.status == Status.approved
      Batch.find(self.batch_id).mark_reviewed
    end
  end

  def complete_approve_package_task
    self.tasks.where(:type_id => Type.approve_package.id).each do |task|
      task.update_attributes(:status_id => Status.completed.id)
    end
  end

  def check_task_statuses
    self.tasks.each do |task|
      task.set_readiness
    end
  end
end
