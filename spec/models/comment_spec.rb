require 'spec_helper'

describe Comment do
  before :each do
    @blog = Factory.create(:blog_unique)
    @user = Factory.create(:user_unique)
    @user.follow! @blog, "lord"
    @comment_author = Factory.create(:user_unique)
    @post = Factory.build(:text)
    @post.author = @user
    @post.blog = @blog
    @post.save!
    @comment = Comment.new(:content => "comm")
    @old_comment_author = Factory.create(:user_unique)
    @comment.author = @old_comment_author
    @post.comments << @comment
  end

  describe "content validations" do
    it "should not blank" do
      @comment.content = nil
      @comment.should_not be_valid
    end
    it "should not empty" do
      @comment.content = ""
      @comment.should_not be_valid
    end
  end

  describe "notice watchers when user comment a post" do
    it "should notice post author" do
      length = @user.comments_notices.unreads.count
      @new_post = Factory.build(:text)
      @new_post.author = @user
      @new_post.blog = @blog
      @new_comment = Comment.new
      @new_comment.author = @comment_author
      @new_comment.content = "just content"
      @new_post.comments << @new_comment
      @new_comment.post.should_not be_nil
      @post.watchers.should be_include(@user)

      @user.reload
      @user.comments_notices.unreads.count.should == 1
    end
  end
end
