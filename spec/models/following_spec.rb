require 'spec_helper'

describe "Following" do

  before :each do
    @user = Factory :user
    @blog = Factory :blog
    @user.follow! @blog, "lord"
  end

  after :each do
    User.delete_all
    Blog.delete_all
  end

  describe "validation" do
    before :each do
      @following = Following.new(:blog => @blog, :auth => "member")
    end

    it "should reject error auths" do
      @following.auth = "other"
      @following.should_not be_valid
    end

    it "should accept correct auths" do
      %w[follower member founder].each do |a|
        @following.auth = a
        @following.should be_valid
      end
    end
  end

  describe "user followings" do

    before :each do
      @blogf = Factory(:blog, :uri=>Factory.next(:uri))
    end

    it "should be in user followings" do
      @user.should respond_to :followings
    end

    it "should have blog" do
      @user.followings.first.blog.should == @blog
    end

    it "should have user" do
      @user.followings.first.user.should == @user
    end

    it "blog should be edited" do
      @blog.edited?(@user).should be_true
    end

    it "blog should be followd" do
      @user.follow! @blog, "follower"
      @blog.followed?(@user).should be_true
    end

    it "should update the same blog following" do
      lambda do
        @user.follow! @blog, "founder"
      end.should_not change(@user.followings, :count)
      @user.followings.first.auth.should == "founder"
    end

    it "should add the different blog following" do
      blog_n = Factory(:blog, :uri =>Factory.next(:uri))
      lambda do
        @user.follow! blog_n, "member"
      end.should change(@user.followings, :count).by(1)
    end

    it "should change the subs and followers" do
      @user.follow! @blogf, "follower"
      @blogf.reload
      @blogf.followers.should be_include @user
      @user.subs.should be_include @blogf
    end

    it "should give the right followers" do
      @blog.reload
      @blog.followers.should be_empty
      @blog.followers_count.should == 0
      userm = Factory(:user, :email => Factory.next(:email))
      userm.follow! @blog, "member"
      userf = Factory(:user, :email => Factory.next(:email))
      userf.follow! @blog
      @blog.reload
      @blog.followers.length.should == 1
      @blog.followers.should include userf
      @user.follow! @blogf
      @blog.followers.length.should == 1
      @blog.followers.should include userf
    end

    it "should give the right founders" do
      @user.follow! @blogf, "founder"
      @user.reload
      @blogf.founders.should include @user
    end

    it "should give the right members" do
      @user.follow! @blogf, "member"
      @user.reload
      @blogf.members.should include @user
    end

  end

  describe "user unfollowing" do

    it "should unfollow the blog" do
      lambda do
        @user.unfollow! @blog
      end.should change(@user.followings, :count).by(-1)
    end
  end

  describe "user blogs" do
    it "should order the blogs by auth" do
      @user.followings = []
      bm = Factory(:blog, :uri =>Factory.next(:uri))
      @user.follow! bm, "member"
      bl = Factory(:blog, :uri =>Factory.next(:uri))
      @user.follow! bl, "lord"
      bf = Factory(:blog, :uri =>Factory.next(:uri))
      @user.follow! bf, "founder"
      @user.blogs.first.should == bl
      @user.blogs.second.should == bf
      @user.blogs.third.should == bm
    end
  end

end
