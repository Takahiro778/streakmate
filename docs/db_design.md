# DB設計まとめ

## ER図
![ER図](er.png)

---

## テーブル一覧
- users
- profiles
- goals
- logs
- cheers
- comments
- follows
- favorites
- notifications
- settings

---

## テーブル詳細

### users テーブル
| Column   | Type   | Options                   |
|----------|--------|---------------------------|
| email    | string | null: false, unique: true |
| password | string | null: false               |

#### Association
- has_one :profile
- has_many :goals
- has_many :logs
- has_many :cheers
- has_many :comments
- has_many :follows
- has_many :favorites
- has_many :notifications
- has_one :setting

---

### profiles テーブル
| Column   | Type       | Options                        |
|----------|------------|--------------------------------|
| user_id  | references | null: false, foreign_key: true |
| name     | string     | null: false                    |
| avatar   | string     |                                |
| bio      | text       |                                |

#### Association
- belongs_to :user

---

### goals テーブル
| Column    | Type       | Options                        |
|-----------|------------|--------------------------------|
| user_id   | references | null: false, foreign_key: true |
| title     | string     | null: false                    |
| detail    | text       |                                |
| is_public | boolean    | default: true                  |

#### Association
- belongs_to :user
- has_many :logs
- has_many :comments
- has_many :favorites

---

### logs テーブル
| Column    | Type       | Options                        |
|-----------|------------|--------------------------------|
| user_id   | references | null: false, foreign_key: true |
| goal_id   | references | null: false, foreign_key: true |
| content   | text       |                                |
| logged_on | date       | null: false                    |

#### Association
- belongs_to :user
- belongs_to :goal
- has_many :cheers
- has_many :comments

---

### cheers テーブル（いいね）
| Column   | Type       | Options                        |
|----------|------------|--------------------------------|
| user_id  | references | null: false, foreign_key: true |
| log_id   | references | null: false, foreign_key: true |

#### Association
- belongs_to :user
- belongs_to :log

#### Index
- add_index [:user_id, :log_id], unique: true

---

### comments テーブル
| Column    | Type       | Options                        |
|-----------|------------|--------------------------------|
| user_id   | references | null: false, foreign_key: true |
| goal_id   | references | foreign_key: true              |
| log_id    | references | foreign_key: true              |
| content   | text       | null: false                    |

#### Association
- belongs_to :user
- belongs_to :goal, optional: true
- belongs_to :log, optional: true

---

### follows テーブル（自己参照）
| Column       | Type       | Options                        |
|--------------|------------|--------------------------------|
| follower_id  | references | null: false, foreign_key: {to_table: :users} |
| followed_id  | references | null: false, foreign_key: {to_table: :users} |

#### Association
- belongs_to :follower, class_name: "User"
- belongs_to :followed, class_name: "User"

#### Index
- add_index [:follower_id, :followed_id], unique: true

---

### favorites テーブル
| Column   | Type       | Options                        |
|----------|------------|--------------------------------|
| user_id  | references | null: false, foreign_key: true |
| goal_id  | references | null: false, foreign_key: true |

#### Association
- belongs_to :user
- belongs_to :goal

#### Index
- add_index [:user_id, :goal_id], unique: true

---

### notifications テーブル
| Column   | Type       | Options                        |
|----------|------------|--------------------------------|
| user_id  | references | null: false, foreign_key: true |
| message  | string     | null: false                    |
| read     | boolean    | default: false                 |

#### Association
- belongs_to :user

---

### settings テーブル
| Column        | Type       | Options                        |
|---------------|------------|--------------------------------|
| user_id       | references | null: false, foreign_key: true |
| reminder_time | time       | default: '23:00'               |
| reminder_on   | boolean    | default: true                  |

#### Association
- belongs_to :user
