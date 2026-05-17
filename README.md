# 🍜 Muse 同城外卖商城

> 缅甸本土一站式外卖生活服务平台，对标美团外卖  
> 技术栈：Vue 3 + Vant 4 + Pinia + Vue Router + Supabase + Vite → Vercel

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/huaxiashanghui-a11y/muse-app)

---

## ✨ 功能模块

| 模块 | 说明 |
|------|------|
| 🏠 首页 | Banner 轮播、快捷入口、附近商家列表 |
| 🍜 外卖 | 商家列表、排序筛选、商家详情、点餐 |
| 🎁 活动中心 | 限时秒杀、优惠券领取、积分任务 |
| 🏅 积分商城 | 积分兑换实物/代金券 |
| 🛒 购物车 | 跨页持久化、一键结算 |
| 👤 个人中心 | 订单管理、地址管理、会员开通 |
| 👥 邀请系统 | 分享裂变、佣金奖励、邀请记录 |
| 👑 会员中心 | 永久会员、9折优惠、积分加倍 |

---

## 🚀 快速部署

### 第一步：初始化 Supabase 数据库

1. 登录 [Supabase Dashboard](https://supabase.com/dashboard)
2. 进入项目 → **SQL Editor**
3. 粘贴并执行 `supabase-schema.sql` 的全部内容
4. 完成后数据库自动插入示例商家、商品、Banner 数据

### 第二步：部署到 Vercel

1. 打开 [Vercel](https://vercel.com) → **Add New Project**
2. 选择 GitHub 仓库 `huaxiashanghui-a11y/muse-app`
3. **Environment Variables** 中添加：

```
VITE_SUPABASE_URL      = https://qrqjibgelgqabdzaikcb.supabase.co
VITE_SUPABASE_ANON_KEY = sb_publishable_PjzI8LWrcUqOzzN0mmWkjA_43IvPZ0L
```

4. 点击 **Deploy** → 等待 2-3 分钟即可访问

---

## 🗂️ 项目结构

```
muse-app/
├── src/
│   ├── assets/         # 全局样式
│   ├── components/
│   │   ├── layout/     # TabLayout 底部导航
│   │   └── home/       # MerchantCard、ProductCard
│   ├── lib/
│   │   └── supabase.js # Supabase 客户端
│   ├── pages/
│   │   ├── home/       # 首页
│   │   ├── food/       # 外卖列表
│   │   ├── activity/   # 活动中心
│   │   ├── shop/       # 积分商城
│   │   ├── cart/       # 购物车
│   │   ├── order/      # 订单确认/列表/详情
│   │   ├── merchant/   # 商家详情/入驻申请
│   │   ├── auth/       # 登录/注册
│   │   ├── invite/     # 邀请好友
│   │   ├── member/     # 会员中心
│   │   ├── points/     # 积分流水
│   │   ├── address/    # 收货地址
│   │   └── profile/    # 个人中心/设置/帮助
│   ├── router/         # Vue Router 路由表
│   ├── stores/         # Pinia：auth/cart/activity
│   ├── App.vue
│   └── main.js
├── supabase-schema.sql # 数据库建表 + 示例数据
├── vercel.json         # Vercel SPA 路由配置
├── vite.config.js
└── package.json
```

---

## 🛠️ 本地开发

```bash
npm install
cp .env.example .env   # 填入 Supabase 配置
npm run dev
```

---

## 📊 数据库表（18张）

`profiles` · `merchants` · `product_categories` · `products` · `banners` · `addresses` · `orders` · `reviews` · `favorites` · `coupons` · `user_coupons` · `point_transactions` · `commission_records` · `flash_sales` · `shop_goods` · `redeem_orders` · `invite_clicks` · `invite_records`

全部开启 **Row Level Security (RLS)**，数据安全有保障。

---

## 🎨 设计规范

- 主色：`#FF6B35`（美团橙）
- 金色：`#F5A623`
- 背景：`#F7F8FA`
- 组件库：Vant 4（移动端）
- 最大宽度：480px（居中适配 PC/移动）

---

*Powered by Muse Team · Built with ❤️ in Yangon*