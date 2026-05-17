<template>
  <tab-layout>
    <div class="page">
      <!-- User card -->
      <div class="user-card gradient-orange" @click="goAuth">
        <div class="avatar">{{ auth.avatar }}</div>
        <div class="user-info" v-if="auth.isLoggedIn">
          <div class="username">{{ auth.nickname }}</div>
          <div class="user-id">ID: {{ auth.inviteCode }}</div>
        </div>
        <div class="user-info" v-else>
          <div class="username">点击登录/注册</div>
          <div class="user-id">登录后享受更多权益</div>
        </div>
        <div class="member-badge" v-if="auth.isMember">👑 会员</div>
      </div>

      <!-- Stats -->
      <div class="stats-row">
        <div class="stat-item" @click="$router.push('/order/list?tab=pending_payment')">
          <div class="stat-val">{{ auth.commission }}</div>
          <div class="stat-key">佣金(K)</div>
        </div>
        <div class="stat-item" @click="$router.push('/points')">
          <div class="stat-val">{{ auth.points }}</div>
          <div class="stat-key">积分</div>
        </div>
        <div class="stat-item" @click="$router.push('/activity?tab=coupon')">
          <div class="stat-val">券</div>
          <div class="stat-key">优惠券</div>
        </div>
        <div class="stat-item" @click="$router.push('/member')">
          <div class="stat-val">{{ auth.isMember ? '已开' : '未开' }}</div>
          <div class="stat-key">会员</div>
        </div>
      </div>

      <!-- Order shortcuts -->
      <div class="card order-card">
        <div class="card-title">我的订单 <span class="more" @click="$router.push('/order/list')">查看全部 ›</span></div>
        <div class="order-icons">
          <div v-for="o in orderShorts" :key="o.name" class="order-icon-item" @click="$router.push(o.path)">
            <van-icon :name="o.icon" size="28" color="#FF6B35" />
            <div>{{ o.name }}</div>
          </div>
        </div>
      </div>

      <!-- Menu -->
      <van-cell-group class="menu-group" inset>
        <van-cell v-for="m in menuItems" :key="m.title" :title="m.title" :icon="m.icon" is-link @click="$router.push(m.path)" />
      </van-cell-group>

      <!-- Invite -->
      <div class="invite-btn gradient-green" @click="$router.push('/invite')">
        👥 邀请好友赚佣金，点击分享
      </div>

      <!-- Logout -->
      <div class="logout-wrap" v-if="auth.isLoggedIn">
        <van-button block plain color="#FF6B35" @click="logout">退出登录</van-button>
      </div>
    </div>
  </tab-layout>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { showConfirmDialog } from 'vant'
import { useAuthStore } from '@/stores/auth'
import TabLayout from '@/components/layout/TabLayout.vue'

const router = useRouter()
const auth = useAuthStore()

function goAuth() { if (!auth.isLoggedIn) router.push('/auth/login') }

const orderShorts = [
  { name: '待付款', icon: 'bill-o', path: '/order/list' },
  { name: '待配送', icon: 'logistics', path: '/order/list' },
  { name: '已完成', icon: 'completed', path: '/order/list' },
  { name: '退款', icon: 'refund-o', path: '/order/list' },
]

const menuItems = [
  { title: '我的收藏', icon: 'like-o', path: '/profile/favorites' },
  { title: '收货地址', icon: 'location-o', path: '/address' },
  { title: '账号安全', icon: 'shield-o', path: '/profile/security' },
  { title: '积分商城', icon: 'medal-o', path: '/shop' },
  { title: '申请入驻商家', icon: 'shop-o', path: '/merchant/apply' },
  { title: '成为骑手', icon: 'tosend', path: '/profile/rider-apply' },
  { title: '帮助中心', icon: 'question-o', path: '/profile/help' },
]

async function logout() {
  await showConfirmDialog({ title: '确认退出', message: '确定要退出登录吗？' })
  await auth.logout()
  router.push('/auth/login')
}
</script>

<style scoped>
.user-card { display:flex; align-items:center; gap:16px; padding:28px 20px; color:#fff; cursor:pointer; }
.avatar { font-size:52px; width:64px; height:64px; border-radius:50%; background:rgba(255,255,255,.2); display:flex; align-items:center; justify-content:center; flex-shrink:0; }
.username { font-size:18px; font-weight:700; }
.user-id { font-size:13px; opacity:.8; margin-top:2px; }
.member-badge { margin-left:auto; background:rgba(255,255,255,.2); padding:4px 10px; border-radius:20px; font-size:13px; }
.stats-row { display:flex; background:#fff; padding:16px 0; margin-bottom:8px; }
.stat-item { flex:1; text-align:center; cursor:pointer; border-right:1px solid #f0f0f0; }
.stat-item:last-child { border-right:none; }
.stat-val { font-size:18px; font-weight:700; color:#222; }
.stat-key { font-size:12px; color:#888; margin-top:2px; }
.card { background:#fff; margin:8px 16px; border-radius:12px; padding:16px; }
.card-title { font-size:15px; font-weight:600; margin-bottom:12px; display:flex; justify-content:space-between; align-items:center; }
.more { font-size:13px; color:#aaa; font-weight:400; }
.order-icons { display:flex; justify-content:space-around; }
.order-icon-item { text-align:center; font-size:12px; color:#555; display:flex; flex-direction:column; align-items:center; gap:6px; cursor:pointer; }
.menu-group { margin:8px 16px !important; }
.invite-btn { margin:16px; padding:14px; border-radius:12px; color:#fff; text-align:center; font-size:15px; font-weight:600; cursor:pointer; }
.logout-wrap { padding:16px; }
</style>