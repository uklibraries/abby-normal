class Batch < ActiveRecord::Base
  belongs_to :batch_type
  belongs_to :server
  belongs_to :status
  has_many :packages, dependent: :destroy
  attr_accessible :dark_archive, :name, :oral_history, :batch_type_id, :server_id, :status_id
  before_create :mark_as_started
  after_create :create_packages
  before_update :check_status
  has_paper_trail

  private

  def mark_as_started
    self.status ||= Status.started
  end

  def create_packages
    # find the right place for this
    base = '/opt/pdp/services/staging/processing'
    path = File.join(
      base,
      self.name,
      'sips'
    )
    limit = 100
    sip_paths = Dir.glob("#{path}/*")
    tickets = (1..sip_paths.count).to_a.shuffle
    sip_paths.each_with_index do |sip_path, i|
      Package.create(
        batch_id: self.id,
        sip_path: sip_path,
        oral_history: self.oral_history,
        dark_archive: self.dark_archive,
        approved: false,
        requires_approval: tickets[i] <= limit
      )
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

  def when_approved
    self.packages.where(status_id: [
      Status.awaiting_approval.id,
      Status.rejected.id,
    ]).each do |package|
      package.status = Status.approved
      package.save
    end

  end
end
