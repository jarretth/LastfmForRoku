require File.dirname(__FILE__) + '/../spec_helper.rb'
require 'roku.rb'

describe Roku, "valid connection" do
  before(:all) do
    @t = Roku.new
  end
  it "it should connect" do
    @t.connect('192.168.2.126',5555).should_not == false
  end
  it "should get roku: ready" do
    @t.recieve.should == "roku: ready"
  end 
  after(:all) do
    @t.close
  end
end

describe Roku,"invalid connection" do
  before(:all) do
    @t = Roku.new
  end
  it "should not connect" do
    @t.connect("1.2.3.4",1).should == false
  end
end