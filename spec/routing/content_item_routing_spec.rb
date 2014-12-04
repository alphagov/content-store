require 'rails_helper'

describe "routing of content_item requests", :type => :routing do
  context "GET route" do
    it "should route to the controller passing on the base_path" do
      expect(:get => "/content/foo/bar").to route_to({
        :controller => "content_items",
        :action => "show",
        :base_path => "/foo/bar",
      })
    end

    it "should not match a base_path without a leading /" do
      expect(:get => "/contentfoo").not_to be_routable
    end
  end

  context "PUT route" do
    it "should route to the controller passing on the base_path" do
      expect(:put => "/content/foo/bar").to route_to({
        :controller => "content_items",
        :action => "update",
        :base_path => "/foo/bar",
      })
    end

    it "should not match a base_path without a leading /" do
      expect(:put => "/contentfoo").not_to be_routable
    end
  end
end
