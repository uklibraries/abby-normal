module ApplicationHelper
  def title(page_title)
    content_for(:title) { page_title }
  end

  def show_title
    content_tag :h1, content_for(:title)
  end

  def display_base_errors resource
    return '' if (resource.errors.empty?) or (resource.errors[:base].empty?)
    messages = resource.errors[:base].map { |msg| content_tag(:p, msg) }.join
    html = <<-HTML
    <div class="alert alert-error alert-block">>
      <button type="button" class="close" data-dismiss="alert">&#215;</button>
      #{messages}
    </div>
    HTML
    html.html_safe
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"

    if column == sort_column
      icon_class = sort_direction == "asc" ? "icon-chevron-up" : "icon-chevron-down"
    end
    link_to "#{title} <i class=\"#{icon_class}\">".html_safe,
            {:sort => column, :direction => direction},
            {:class => css_class}

  end

  def live_link(package)
    if package.dip_identifier
      batch = Batch.find(package.batch_id)
      type = BatchType.find(batch.batch_type_id).name
      test_site = 'http://kdl.kyvl.org/catalog'
      dip_id = package.dip_identifier + (['EAD', 'oral history'].include?(type) ? "" : "_1")
      "#{test_site}/#{dip_id}"
    end
  end

  def inspection_link(package)
    if package.dip_identifier
      batch = Batch.find(package.batch_id)
      type = BatchType.find(batch.batch_type_id).name
      test_site = 'http://kdl.kyvl.org/test/catalog'
      dip_id = package.dip_identifier + (['EAD', 'oral history'].include?(type) ? "" : "_1")
      "#{test_site}/#{dip_id}"
    end
  end

  def discussion_link(package)
    Batch.find(package.batch_id).discussion_link
  end
end
