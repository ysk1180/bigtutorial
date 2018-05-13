class PostsController < ApplicationController
  # ①:edit, :destroy, showを消去、:confirmを追加
  before_action :set_post, only: [:confirm, :edit, :update]
  # ②追加
  before_action :new_post, only: [:show, :new]

  # ③showアクション修正
  def show
    # ③-1 投稿idをセット（idの有無をTwitterに表示させる画像を決める条件分岐に使用するため）
    @post.id = params[:id]
    # ③-2 showアクションが呼ばれた場合、new.html.erbを呼び出す
    render :new
  end

  # ④インスタンス生成はbefore_action :new_postに集約
  def new
  end

  def edit
  end

  # ⑤createアクションを修正
  def create
    # ⑤-1 @postに入力したcontent、kindが入っています。（id、pictureはまだ入っていません）
    @post = Post.new(post_params)
    # ⑤-2 idとして採番予定の数字を作成（現在作成しているidの次）
    next_id = Post.last.id + 1
    # ⑤-3 画像の生成メソッド呼び出し（画像のファイル名にidを使うため、引数として渡す）
    make_picture(next_id)
    if @post.save
      # ⑤-4 確認画面へリダイレクト
      redirect_to confirm_path(@post)
    else
      render :new
    end
  end

  # ⑥createアクションを修正
  def update
    if @post.update(post_params)
      make_picture(@post.id)
      redirect_to confirm_path(@post)
    else
      render :edit
    end
  end

  # ⑦confirmアクションを追加
  def confirm
  end

  private
  def set_post
    @post = Post.find(params[:id])
  end

  # ⑧メソッド追加
  def new_post
    @post = Post.new
  end

  def post_params
    params.require(:post).permit(:content, :picture, :kind)
  end

  # ⑨メソッド追加（画像生成）
  def make_picture(id)
    sentense = ""
    # ⑨-1 改行を消去
    content = @post.content.gsub(/\r\n|\r|\n/," ")
    # ⑨-2 contentの文字数に応じて条件分岐
    if content.length <= 28 then
      # ⑨-3 28文字以下の場合は7文字毎に改行
      n = (content.length / 7).floor + 1
      n.times do |i|
        s_num = i * 7
        f_num = s_num + 6
        range =  Range.new(s_num,f_num)
        sentense += content.slice(range)
        sentense += "\n" if n != i+1
      end
      # ⑨-4 文字サイズの指定
      pointsize = 90
    elsif content.length <= 50 then
      n = (content.length / 10).floor + 1
      n.times do |i|
        s_num = i * 10
        f_num = s_num + 9
        range =  Range.new(s_num,f_num)
        sentense += content.slice(range)
        sentense += "\n" if n != i+1
      end
      pointsize = 60
    else
      n = (content.length / 15).floor + 1
      n.times do |i|
        s_num = i * 15
        f_num = s_num + 14
        range =  Range.new(s_num,f_num)
        sentense += content.slice(range)
        sentense += "\n" if n != i+1
      end
      pointsize = 45
    end
    # ⑨-5 文字色の指定
    color = "white"
    # ⑨-6 文字を入れる場所の調整（0,0を変えると文字の位置が変わります）
    draw = "text 0,0 '#{sentense}'"
    # ⑨-7 フォントの指定
    font = ".fonts/GenEiGothicN-U-KL.otf"
    # ⑨-8 ↑これらの項目も文字サイズのように背景画像や文字数によって変えることができます
    # ⑨-9 選択された背景画像の設定
    case @post.kind
    when "black" then
      base = "black.jpg"
    # ⑨-10 今回は選択されていない場合は"red"となるようにしている
    else
      base = "red.jpg"
    end
    # ⑨-11 minimagickを使って選択した画像を開き、作成した文字を指定した条件通りに挿入している
    image = MiniMagick::Image.open(base)
    image.combine_options do |i|
      i.font font
      i.fill color
      i.gravity 'center'
      i.pointsize pointsize
      i.draw draw
    end
    # ⑨-12 保存先のストレージの指定。Amazon S3を指定する。
    storage = Fog::Storage.new(
      provider: 'AWS',
      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      region: 'ap-northeast-1'
    )
    # ⑨-13 開発環境or本番環境でS3のバケット（フォルダのようなもの）を分ける
    case Rails.env
      when 'production'
        # ⑨-14 バケットの指定・URLの設定（bigtutorialの箇所は管理しやすいよう各自設定したアプリ名として下さい）
        bucket = storage.directories.get('bigtutorial-production')
        # ⑨-15 保存するディレクトリ、ファイル名の指定（ファイル名は投稿id.pngとしています）
        png_path = 'images/' + id.to_s + '.png'
        image_uri = image.path
        file = bucket.files.create(key: png_path, public: true, body: open(image_uri))
        @post.picture = 'https://s3-ap-northeast-1.amazonaws.com/bigtutorial-production' + "/" + png_path
      when 'development'
        bucket = storage.directories.get('bigtutorial-development')
        png_path = 'images/' + id.to_s + '.png'
        image_uri = image.path
        file = bucket.files.create(key: png_path, public: true, body: open(image_uri))
        @post.picture = 'https://s3-ap-northeast-1.amazonaws.com/bigtutorial-development' + "/" + png_path
    end
  end
end
