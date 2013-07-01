class AddDiscussionLinkToBatches < ActiveRecord::Migration
  def change
    add_column :batches, :discussion_link, :string
  end
end
