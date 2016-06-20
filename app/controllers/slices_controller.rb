class SlicesController < ActionController::Base
  include ActiveSupport::Benchmarkable

  protect_from_forgery

  rescue_from Page::NotFound, with: :render_not_found

  append_view_path(File.join(Rails.root, *%w[app slices]))

  define_callbacks :render_page, terminator: "response_body"

  def self.should_raise_exceptions?
    !Rails.env.production?
  end

  protected

  def render_not_found
    render_not_found!
  end

  def render_not_found!
    logger.warn "404: #{request.path} :: #{request.params.inspect}"
    render :file => 'public/404.html', :status => :not_found, :layout => false
  end

  private

  def render_page(page, status = 200)
    @page = page

    run_callbacks :render_page do
      ordered_slices = nil
      benchmark 'Page.ordered_slices' do
        ordered_slices = page_or_parent_slices
      end
      @slice_renderer = Slices::Renderer.new(
        controller:   self,
        current_page: @page,
        params:       params,
        slices:       ordered_slices
      )
      render text: '', layout: page_layout(@page), status: status
    end
  end

  def page_or_parent_slices
    @page.entry? ? @page.parent.ordered_set_slices : @page.ordered_slices
  end

  def page_layout(page)
    page.layout
  end
end
