# -*- encoding: utf-8 -*-
require 'spec_helper'

describe "The page layout selector", type: :request, js: true do

  before do
    home, my_page = StandardTree.build_minimal_with_slices
    my_page.update_attributes(layout: "layout_one")
    sign_in_as_admin
    visit admin_page_path my_page
    click_on "advanced options…"
  end

  subject do
    page
  end

  it "exists, with the expected options, and expected value selected" do
    is_expected.to have_select "meta-layout", options: [
      "Default",
      "Broken",
      "Layout One",
      "Layout Two",
      "Layout Yield",
      "One Container"
    ], selected: "Layout One"
  end

  it "saves successfully" do
    select "Layout Two", from: "Layout"
    click_on_save_changes
    is_expected.to have_select "meta-layout", selected: "Layout Two"
  end

end

