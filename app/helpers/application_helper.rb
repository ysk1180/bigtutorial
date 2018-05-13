module ApplicationHelper
  def get_twitter_card_info(post)
    twitter_card = {}
    if post.present?
      if post.id.present?
        twitter_card[:url] = "https://bigtutorial.herokuapp.com/posts/#{post.id}"
        twitter_card[:image] = "https://s3-ap-northeast-1.amazonaws.com/bigtutorial-production/images/#{post.id}.png"
      else
        twitter_card[:url] = 'https://bigtutorial.herokuapp.com/'
        twitter_card[:image] = "https://raw.githubusercontent.com/ysk1180/bigtutorial/master/app/assets/images/top.png"
      end
    else
      twitter_card[:url] = 'https://bigtutorial.herokuapp.com/'
      twitter_card[:image] = "https://raw.githubusercontent.com/ysk1180/bigtutorial/master/app/assets/images/top.png"
    end
    twitter_card[:title] = "Big Tutorial"
    twitter_card[:card] = 'summary_large_image'
    twitter_card[:description] = 'BigTweetのチュートリアル作成しました！'
    twitter_card
  end
end
