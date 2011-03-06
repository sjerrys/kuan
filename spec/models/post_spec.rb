require 'spec_helper'

describe Post do
  #pending "Abstract class, dunno what to do"

  describe "notice watchers when usre comment a post" do
    before :each do
      @blog = Factory.build(:blog_unique)
      @following = Factory.build(:following_lord, :blog => @blog)
      @user = Factory.build(:user_unique, :followings => [@following])
      @comment_author = Factory.build(:user_unique)
      @comment_user = Factory.build(:user_unique)
      @post = Post.new
      @post.author = @user
    end
      
    it "should notice post author" do
      length = @user.comments_notices.unread.count
      @comment = Factory.build(:comment, :post => @post, :author => @comment_author)
      @post.notify_watchers(@comment)
      @user.comments_notices.unread.count.should == length + 1
    end

    it "should notice other comment user" do
      @comment_old = Factory.build(:comment, :post => @post, :author => @comment_user)
      length = @comment_user.comments_notices.unread.count
      @comment = Factory.build(:comment, :post => @post, :author => @comment_author)
      @post.notify_watchers(@comment)
      @comment_user.comments_notices.unread.count.should == length + 1
    end

    it "should not notice self" do
      @comment_old = Factory.build(:comment, :post => @post, :author => @comment_user)
      length = @comment_author.comments_notices.unread.count
      @comment = Factory.build(:comment, :post => @post, :author => @comment_author)
      @post.notify_watchers(@comment)
      @comment_author.comments_notices.unread.count.should == length
    end

    it "should not notice same user twice" do
      Factory.build(:comment, :post => @post, :author => @comment_user)
      Factory.build(:comment, :post => @post, :author => @comment_user)
      length = @comment_user.comments_notices.unread.count
      @comment = Factory.build(:comment, :post => @post, :author => @comment_author)
      @post.notify_watchers(@comment)
      @comment_user.comments_notices.unread.count.should == length + 1
    end

    it "should list all watchers" do
      @comment = Comment.new
      @comment.post = @post
      @comment.author = @comment_user
      @comment.save
      watchers = @post.watchers
      watchers.should be_include(@post.author)
      watchers.should be_include(@comment_user)
    end
  end
end

describe Post, "Rich text filtering" do
  before :each do
    email = Factory.next :email
    uri = Factory.next :uri
    @author = Factory :user, email: email
    @blog = Factory :blog, uri: uri
    @author.follow! @blog, "founder"
    @post = Factory.build :text, author: @author, blog: @blog
  end

  describe "given a simple rich text input with every tag and attr in whitelist" do
    before :each do
      @orig_content = '<a href="http://g.cn" shit="true">blah</a>'
      @expected = '<a href="http://g.cn">blah</a>'
      @post.content = @orig_content
    end

    it "should not mess it up but strip junk" do
      @post.save!
      @post.reload
      @post.content.should == @expected
    end
  end

  describe "given a text input with nothing but malicious" do
    before :each do
      @orig_content = <<EOF
<script type="text/javascript">alert("you fool!")<script>
EOF
      @post.content = @orig_content
      @post.save!
      @post.reload
    end

    it "should trim it to empty" do
      @post.content.should be_blank
    end
  end

  describe "given a plain text input" do
    before :each do
      @orig_content = @post.content
    end

    describe "and save it" do
      before :each do
        @post.save!
        @post.reload
      end

      it "should not mess it up" do
        @post.content.should == @orig_content
      end
    end
  end

  describe "let's play with M$ style expressions" do
    before :each do
      @orig_content = '<p style="text-decoration: underline; width: expression(alert(\'yeeha\'))">!</p>'
      @expected = '<p style="text-decoration: underline">!</p>'
      @post.content = @orig_content
    end

    it "should clean it up" do
      @post.save!
      @post.reload
      @post.content.should == @expected
    end
  end

  describe "funcky url?" do
    before :each do
      @orig_content = '<img src="j&amp;97;vascript:alert(document.cookie) />"'
      @expected = '<img src="">'
      @post.content = @orig_content
    end

    it "should clean it up" do
      @post.save!
      @post.reload
      @post.content.should == @expected
    end
  end

  describe "given a raw url post" do
    before :each do
      @orig_content = 'http://g.cn'
      @expected = '<a href="http://g.cn">http://g.cn</a>'
      @post.content = @orig_content
      @post.save!
      @post.reload
    end

    it "should wrap <a> around it" do
      @post.content.should == @expected
    end

    describe "but not again!" do
      it "should do nothing further" do
        content = @post.content
        @post.content = content
        @post.save!
        @post.reload
        @post.content.should == content
      end
    end
  end
end
