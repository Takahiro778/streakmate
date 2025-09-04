# Database Design

## ER 図
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

### users
| Column             | Type     | Options                   |
|--------------------|----------|---------------------------|
| email              | string   | null: false, unique: true |
| encrypted_password | string   | null: false               |
| created_at         | datetime | null: false               |
| updated_at         | datetime | null: false               |

**Index**
- add_index :users, :email, unique: true

**Association**
- has_one :profile, dependent: :destroy
- has_many :goals, :logs, :cheers, :comments, :favorites, :notifications, dependent: :destroy
- has_one :setting, dependent: :destroy
- has_many :active_follows,  class_name: "Follow", foreign_key: :follower_id
- has_many :passive_follows, class_name: "Follow", foreign_key: :followed_id

---

### profiles
| Column     | Type       | Options                        |
|------------|------------|--------------------------------|
| user_id    | references | null: false, foreign_key: true |
| name       | string     | null: false                    |
| avatar     | string     |                                |
| bio        | text       |                                |
| created_at | datetime   | null: false                    |
| updated_at | datetime   | null: false                    |

**Index**
- add_index :profiles, :user_id, unique: true

---

### goals
| Column     | Type       | Options                        |
|------------|------------|--------------------------------|
| user_id    | references | null: false, foreign_key: true |
| title      | string     | null: false                    |
| detail     | text       |                                |
| is_public  | boolean    | default: true                  |
| created_at | datetime   | null: false                    |
| updated_at | datetime   | null: false                    |

**Index**
- add_index :goals, [:user_id, :is_public]

---

### logs
| Column     | Type       | Options                        |
|------------|------------|--------------------------------|
| user_id    | references | null: false, foreign_key: true |
| goal_id    | references | null: false, foreign_key: true |
| content    | text       |                                |
| logged_on  | date       | null: false                    |
| minutes    | integer    | default: 0, null: false        |
| visibility | integer    | default: 0                     |
| created_at | datetime   | null: false                    |
| updated_at | datetime   | null: false                    |

**Index**
- add_index :logs, [:user_id, :logged_on]
- add_index :logs, :goal_id

**Enum（例）**
- visibility: { public: 0, followers: 1, private: 2 }

---

### cheers
| Column     | Type       | Options                        |
|------------|------------|--------------------------------|
| user_id    | references | null: false, foreign_key: true |
| log_id     | references | null: false, foreign_key: true |
| created_at | datetime   | null: false                    |
| updated_at | datetime   | null: false                    |

**Index**
- add_index :cheers, [:user_id, :log_id], unique: true

---

### comments
| Column     | Type       | Options                        |
|------------|------------|--------------------------------|
| user_id    | references | null: false, foreign_key: true |
| goal_id    | references | foreign_key: true              |
| log_id     | references | foreign_key: true              |
| content    | text       | null: false                    |
| created_at | datetime   | null: false                    |
| updated_at | datetime   | null: false                    |

**Validation**
- goal_id または log_id のいずれか必須

---

### follows
| Column       | Type       | Options                                      |
|--------------|------------|----------------------------------------------|
| follower_id  | references | null: false, foreign_key: { to_table: :users } |
| followed_id  | references | null: false, foreign_key: { to_table: :users } |
| created_at   | datetime   | null: false                                  |
| updated_at   | datetime   | null: false                                  |

**Index**
- add_index :follows, [:follower_id, :followed_id], unique: true

---

### favorites
| Column     | Type       | Options                        |
|------------|------------|--------------------------------|
| user_id    | references | null: false, foreign_key: true |
| goal_id    | references | null: false, foreign_key: true |
| created_at | datetime   | null: false                    |
| updated_at | datetime   | null: false                    |

**Index**
- add_index :favorites, [:user_id, :goal_id], unique: true

---

### notifications（ポリモーフィック設計）
| Column          | Type       | Options                                   |
|-----------------|------------|-------------------------------------------|
| user_id         | references | null: false, foreign_key: true            |
| actor_id        | references | null: false, foreign_key: { to_table: :users } |
| notifiable_type | string     | null: false                               |
| notifiable_id   | bigint     | null: false                               |
| action          | string     | null: false                               |
| read_at         | datetime   |                                           |
| created_at      | datetime   | null: false                               |
| updated_at      | datetime   | null: false                               |

**Index**
- add_index :notifications, [:user_id, :read_at]
- add_index :notifications, [:notifiable_type, :notifiable_id]

---

### settings
| Column        | Type       | Options                        |
|---------------|------------|--------------------------------|
| user_id       | references | null: false, foreign_key: true |
| reminder_time | time       | default: '23:00'               |
| reminder_on   | boolean    | default: true                  |
| created_at    | datetime   | null: false                    |
| updated_at    | datetime   | null: false                    |
