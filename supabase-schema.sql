-- Muse同城外卖商城 Supabase数据库表结构
-- 在 Supabase Dashboard → SQL Editor 中执行此文件

-- 1. 用户资料表
create table if not exists profiles (
  id uuid references auth.users(id) primary key,
  nickname text,
  avatar text default '🧑',
  display_id text,
  phone text,
  points integer default 0,
  commission decimal(10,2) default 0,
  is_member boolean default false,
  streak_days integer default 0,
  invite_count integer default 0,
  created_at timestamptz default now()
);
alter table profiles enable row level security;
create policy "Users can read/write own profile" on profiles
  using (auth.uid() = id) with check (auth.uid() = id);

-- 2. 商家表
create table if not exists merchants (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  logo_url text,
  emoji text default '🏪',
  cover_color text,
  rating decimal(2,1) default 4.8,
  monthly_sales integer default 0,
  distance text,
  delivery_time integer default 30,
  min_order decimal(10,2) default 15,
  delivery_fee decimal(10,2) default 2.5,
  promotions text[],
  business_hours text default '09:00-22:00',
  address text,
  delivery_range text default '5公里',
  is_active boolean default true,
  sort_order integer default 0,
  created_at timestamptz default now()
);
alter table merchants enable row level security;
create policy "Anyone can read active merchants" on merchants for select using (is_active = true);

-- 3. 商品分类表
create table if not exists product_categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  sort_order integer default 0
);

-- 4. 商品表
create table if not exists products (
  id uuid primary key default gen_random_uuid(),
  merchant_id uuid references merchants(id),
  category_id uuid references product_categories(id),
  name text not null,
  spec text,
  price decimal(10,2) not null,
  image_url text,
  emoji text default '🍜',
  label text,
  is_active boolean default true,
  sort_order integer default 0,
  created_at timestamptz default now()
);
alter table products enable row level security;
create policy "Anyone can read active products" on products for select using (is_active = true);

-- 5. Banner广告表
create table if not exists banners (
  id uuid primary key default gen_random_uuid(),
  title text,
  subtitle text,
  emoji text,
  bg_color text,
  image_url text,
  link_url text,
  position text default 'home',
  is_active boolean default true,
  sort_order integer default 0
);
alter table banners enable row level security;
create policy "Anyone can read banners" on banners for select using (is_active = true);

-- 6. 收货地址表
create table if not exists addresses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id),
  name text not null,
  phone text not null,
  detail text not null,
  tag text default '其他',
  is_default boolean default false,
  created_at timestamptz default now()
);
alter table addresses enable row level security;
create policy "Users can CRUD own addresses" on addresses
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- 7. 订单表
create table if not exists orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id),
  merchant_id uuid references merchants(id),
  items jsonb,
  total_amount decimal(10,2),
  delivery_fee decimal(10,2) default 2.5,
  discount_amount decimal(10,2) default 0,
  points_used integer default 0,
  pay_method text default 'wechat',
  delivery_mode text default 'delivery',
  address_id uuid references addresses(id),
  remark text,
  status text default 'pending_payment',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
alter table orders enable row level security;
create policy "Users can read own orders" on orders for select using (auth.uid() = user_id);
create policy "Users can create orders" on orders for insert with check (auth.uid() = user_id);
create policy "Users can update own orders" on orders for update using (auth.uid() = user_id);

-- 8. 评论表
create table if not exists reviews (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id),
  merchant_id uuid references merchants(id),
  order_id uuid references orders(id),
  rating integer check (rating between 1 and 5),
  content text,
  created_at timestamptz default now()
);
alter table reviews enable row level security;
create policy "Anyone can read reviews" on reviews for select using (true);
create policy "Auth users can create reviews" on reviews for insert with check (auth.uid() = user_id);

-- 9. 收藏表
create table if not exists favorites (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id),
  merchant_id uuid references merchants(id),
  product_id uuid references products(id),
  type text not null,
  created_at timestamptz default now(),
  unique (user_id, merchant_id, type),
  unique (user_id, product_id, type)
);
alter table favorites enable row level security;
create policy "Users CRUD own favorites" on favorites
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- 10. 优惠券模板表
create table if not exists coupons (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  type text not null,
  value decimal(10,2) not null,
  min_order decimal(10,2) default 0,
  expire_days integer default 30,
  remaining integer default 999,
  is_public boolean default true,
  sort_order integer default 0,
  created_at timestamptz default now()
);
alter table coupons enable row level security;
create policy "Anyone can read coupons" on coupons for select using (is_public = true);

-- 11. 用户券包表
create table if not exists user_coupons (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id),
  coupon_id uuid references coupons(id),
  is_used boolean default false,
  used_at timestamptz,
  expires_at timestamptz,
  created_at timestamptz default now()
);
alter table user_coupons enable row level security;
create policy "Users CRUD own coupons" on user_coupons
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- 12. 积分流水表
create table if not exists point_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id),
  points integer not null,
  type text,
  description text,
  created_at timestamptz default now()
);
alter table point_transactions enable row level security;
create policy "Users can read/create own point_transactions" on point_transactions
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- 13. 佣金记录表
create table if not exists commission_records (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id),
  amount decimal(10,2) not null,
  type text,
  description text,
  invitee_id uuid references auth.users(id),
  created_at timestamptz default now()
);
alter table commission_records enable row level security;
create policy "Users read own commission" on commission_records for select using (auth.uid() = user_id);

-- 14. 限时秒杀表
create table if not exists flash_sales (
  id uuid primary key default gen_random_uuid(),
  product_id uuid references products(id),
  merchant_id uuid references merchants(id),
  name text,
  emoji text,
  original_price decimal(10,2),
  flash_price decimal(10,2),
  stock integer default 100,
  sold integer default 0,
  start_time timestamptz,
  end_time timestamptz,
  is_active boolean default true
);
alter table flash_sales enable row level security;
create policy "Anyone can read flash_sales" on flash_sales for select using (true);

-- 15. 积分商城商品表
create table if not exists shop_goods (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  emoji text default '🎁',
  section text default '通用区',
  market_price decimal(10,2),
  pts_required integer not null,
  stock integer default 999,
  is_active boolean default true,
  sort_order integer default 0
);
alter table shop_goods enable row level security;
create policy "Anyone can read shop_goods" on shop_goods for select using (is_active = true);

-- 16. 兑换订单表
create table if not exists redeem_orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id),
  goods_id uuid references shop_goods(id),
  pts_used integer,
  status text default 'pending',
  created_at timestamptz default now()
);
alter table redeem_orders enable row level security;
create policy "Users CRUD own redeem_orders" on redeem_orders
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- 17. 邀请点击记录表
create table if not exists invite_clicks (
  id bigint primary key generated always as identity,
  inviter_id uuid references auth.users(id),
  invite_code text,
  channel text,
  click_ip text,
  click_ua text,
  is_registered boolean default false,
  registered_user_id uuid,
  clicked_at timestamptz default now(),
  expired_at timestamptz default (now() + interval '30 days')
);
alter table invite_clicks enable row level security;
create policy "Users can insert invite_clicks" on invite_clicks for insert with check (true);

-- 18. 邀请关系表
create table if not exists invite_records (
  id bigint primary key generated always as identity,
  inviter_id uuid references auth.users(id),
  invitee_id uuid references auth.users(id),
  invite_code text,
  channel text,
  registered_at timestamptz default now(),
  first_order_at timestamptz,
  first_order_id uuid,
  is_activated boolean default false,
  inviter_reward_pts integer default 0,
  inviter_reward_cash decimal(10,2) default 0,
  level integer default 1,
  status text default 'active'
);
alter table invite_records enable row level security;
create policy "Users read own invite_records" on invite_records for select using (auth.uid() = inviter_id or auth.uid() = invitee_id);

-- ═══════ 示例数据 ═══════

insert into merchants (name, emoji, rating, monthly_sales, distance, delivery_time, min_order, delivery_fee, promotions, is_active, sort_order) values
('奶茶小镇', '🧋', 4.9, 1200, '0.8km', 20, 15, 2,   ARRAY['满25减3','满38减8'], true, 1),
('美味炸鸡', '🍗', 4.7, 980,  '1.2km', 25, 20, 2.5, ARRAY['满38减8'], true, 2),
('咖啡工坊', '☕', 4.8, 650,  '0.5km', 15, 25, 0,   ARRAY['满50减10'], true, 3),
('快乐便当', '🍱', 4.6, 800,  '1.5km', 30, 15, 2.5, ARRAY['满25减3','满72减15'], true, 4),
('水果捞捞', '🍓', 4.5, 400,  '2.0km', 35, 20, 3,   ARRAY['满38减8'], true, 5),
('烤肉物语', '🥩', 4.8, 550,  '1.8km', 40, 30, 3,   ARRAY['满50减10'], true, 6);

insert into products (merchant_id, name, spec, price, emoji, label, is_active, sort_order)
select m.id, p.name, p.spec, p.price, p.emoji, p.label, true, p.so
from merchants m, (values
  ('珍珠奶茶','700ml · 经典款', 8.00,'🧋','热销',1),
  ('芝士奶茶','700ml · 芝士满满',12.00,'🧋','推荐',2),
  ('抹茶拿铁','500ml · 日式抹茶',16.00,'☕','新品',3),
  ('经典炸鸡','2块 · 香辣/原味', 22.00,'🍗','热销',4),
  ('卡布奇诺','350ml · 意式浓缩',18.00,'☕','推荐',5)
) as p(name,spec,price,emoji,label,so)
where m.name = '奶茶小镇';

insert into banners (title,subtitle,emoji,bg_color,position,is_active,sort_order) values
('Muse外卖','缅甸本土一站式生活服务','🍜','linear-gradient(135deg,#FF6B35,#F5A623)','home',true,1),
('限时特惠','下单立减，好味更实惠','🎁','linear-gradient(135deg,#7B2FF7,#4B79F7)','home',true,2),
('邀请好友','分享赚佣金，朋友同享优惠','👥','linear-gradient(135deg,#11998e,#38ef7d)','home',true,3);

insert into coupons (name,type,value,min_order,expire_days,remaining,is_public,sort_order) values
('新人专享券','cash',10,25,7,999,true,1),
('周末特惠券','cash',5,38,3,200,true,2),
('会员折扣券','discount',0.9,50,30,100,true,3);

insert into shop_goods (name,emoji,section,market_price,pts_required,is_active,sort_order) values
('美妆礼品卡','💄','美妆专区',50,5000,true,1),
('咖啡优惠券','☕','餐饮专区',20,2000,true,2),
('平台代金券','🎟','通用区',10,1000,true,3),
('积分加速卡','⚡','通用区',30,3000,true,4),
('外卖抵扣券','🍜','餐饮专区',15,1500,true,5);

insert into flash_sales (name,emoji,original_price,flash_price,stock,sold,is_active) values
('珍珠奶茶秒杀','🧋',8,4.9,100,60,true),
('炸鸡桶特惠','🍗',38,19.9,50,30,true),
('咖啡买一送一','☕',18,9,80,45,true);