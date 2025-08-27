class Category < ActiveHash::Base
  self.data = [
    { id: 1, name: '学習' },
    { id: 2, name: '健康' },
    { id: 3, name: '仕事' },
    { id: 4, name: '生活' },
  ]
  include ActiveHash::Associations
  has_many :goals
end
