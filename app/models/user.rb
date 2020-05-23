class User < ApplicationRecord
  before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  
  has_many :microposts
  has_many :relationships #自分をフォローしているUserへの参照
  has_many :followings, through: :relationships, source: :follow
  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id' #自分がフォローしているUserの参照
  has_many :followers, through: :reverses_of_relationship, source: :user

=begin
リレーションについて
has_many :followings, through: :relationships, source: :follow の場合
　➘「has_many :followingsという関係を命名し、「フォローしているUserたちを表現
　　「through :relationsips」の記述で「has_many: relationsips」の結果を中間テーブルとして指定している。
さらに、その中間テーブルのカラムの中でどれを参照先のidとすべきかを「source: :follow」で選択。
結果として
　「user.followings」というメソッドを用いるとuserが中間テーブルrelationshipsを取得し、その１つ１つの
　relationshipのfollow_idから自分がフォローしているUser達を取得する処理が可能となる。
　
　---------------------------------------------------------------------------------
　☆中間テーブルを経由して、相手の情報取得できるようにするためにはthroughを使用する。
　----------------------------------------------------------------------------------
=end

  def follow(other_user) #フォローしようとしているother_userが自分自身ではないか？
    unless self == other_user
      self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end
  
  def unfollow(other_user) #フォローがあればアンフォローする（destroy）
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end
  
  def following?(other_user) #self.followingsによりフォローしているUserを取得し、include?(other_user)によって、other_userが含まれていないかを確認する
    self.followings.include?(other_user)
  end
  
=begin
  ------------------------------------------------------------------------------------
  フォロー/アンフォローするときは
  　・自分自身ではないか？
  　・すでにフォローしているか？
  を分岐条件にする
  ------------------------------------------------------------------------------------
=end
end