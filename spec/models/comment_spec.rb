require 'spec_helper'

describe Comment do
  before :each do
    @comment = Factory :comment
  end

  after :each do
  end

  describe "content validations" do
    it "should not blank" do
      @comment.content = ""
      @comment.should_not be_valid
    end
    it "should reject too long content" do
      @comment.content = "a"*1001
      @comment.should_not be_valid
    end
  end
end
