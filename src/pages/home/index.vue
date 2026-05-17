<template>
  <tab-layout>
    <div class="page">
      <div class="top-bar">
        <div class="location" @click="showToast('定位功能')">
          <van-icon name="location-o" color="#FF6B35" />
          <span>仰光市区</span>
          <van-icon name="arrow-down" size="12" />
        </div>
        <van-icon name="service-o" size="22" color="#FF6B35" @click="showToast('客服联系中')" />
      </div>
      <van-search v-model="keyword" placeholder="搜索商家、菜品" shape="round" readonly @click="showToast('搜索功能开发中')" class="search-bar" />

      <van-pull-refresh v-model="refreshing" @refresh="onRefresh">
        <!-- Banner -->
        <van-swipe class="banner-swipe" :autoplay="3000" indicator-color="#FF6B35">
          <van-swipe-item v-for="b in banners" :key="b.id">
            <div class="banner-item" :style="`background:${b.bg_color}`">
              <div class="banner-emoji">{{ b.emoji }}</div>
              <div class="banner-text">
                <div class="banner-title">{{ b.title }}</div>
                <div class="banner-sub">{{ b.subtitle }}</div>
              </div>
            </div>
          </van-swipe-item>
        </van-swipe>

        <!-- Quick services -->
        <div class="quick-grid">
          <div v-for="s in quickServices" :key="s.name" class="quick-item" @click="onQuick(s)">
            <div class="quick-icon" :style="`background:${s.color}`">{{ s.icon }}</div>
            <div class="quick-name">{{ s.name }}</div>
          </div>
        </div>

        <!-- Invite banner -->
        <div class="invite-banner gradient-green" @click="$router.push('/invite')">
          <span>👥 邀请好友，赚佣金 K200</span>
          <van-icon name="arrow" color="#fff" />
        </div>

        <!-- Merchants -->
        <div class="section-title">附近商家</div>
        <div v-if="loading" class="loading-wrap"><van-loading color="#FF6B35" /></div>
        <merchant-card v-else v-for="m in merchants" :key="m.id" :m="m" />
        <div class="list-end" v-if="!loading">已显示全部商家</div>
      </van-pull-refresh>
    </div>
  </tab-layout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { showToast } from 'vant'
import { supabase } from '@/lib/supabase'
import { useRouter } from 'vue-router'
import TabLayout from '@/components/layout/TabLayout.vue'
import MerchantCard from '@/components/home/MerchantCard.vue'

const router = useRouter()
const keyword = ref('')
const refreshing = ref(false)
const loading = ref(true)
const banners = ref([])
const merchants = ref([])

const quickServices = [
  { name: '外卖', icon: '🍜', color: '#fff3ee', path: '/food' },
  { name: '活动', icon: '🎁', color: '#f0eaff', path: '/activity' },
  { name: '积分商城', icon: '🎟', color: '#e8f5e9', path: '/shop' },
  { name: '邀请', icon: '👥', color: '#e3f2fd', path: '/invite' },
  { name: '优惠券', icon: '🏷', color: '#fff8e1', path: '/activity' },
  { name: '会员', icon: '👑', color: '#fce4ec', path: '/member' },
  { name: '我的订单', icon: '📦', color: '#f3e5f5', path: '/order/list' },
  { name: '帮助', icon: '💬', color: '#e0f7fa', path: '/profile/help' },
]

function onQuick(s) { router.push(s.path) }

async function fetchData() {
  loading.value = true
  const [{ data: b }, { data: m }] = await Promise.all([
    supabase.from('banners').select('*').eq('is_active', true).eq('position', 'home').order('sort_order'),
    supabase.from('merchants').select('*').eq('is_active', true).order('sort_order').limit(20),
  ])
  banners.value = b || []
  merchants.value = m || []
  loading.value = false
}

async function onRefresh() {
  await fetchData()
  refreshing.value = false
}

onMounted(fetchData)
</script>

<style scoped>
.top-bar { display:flex; align-items:center; justify-content:space-between; padding:12px 16px 0; }
.location { display:flex; align-items:center; gap:4px; font-size:15px; font-weight:600; cursor:pointer; }
.search-bar { padding:8px 16px; }
.banner-swipe { height:140px; margin:0 16px; border-radius:12px; overflow:hidden; }
.banner-item { height:140px; display:flex; align-items:center; gap:16px; padding:20px; }
.banner-emoji { font-size:52px; }
.banner-title { font-size:18px; font-weight:800; color:#fff; }
.banner-sub { font-size:13px; color:rgba(255,255,255,.85); margin-top:4px; }
.quick-grid { display:grid; grid-template-columns:repeat(4,1fr); gap:12px; padding:16px; }
.quick-item { display:flex; flex-direction:column; align-items:center; gap:6px; cursor:pointer; }
.quick-icon { width:52px; height:52px; border-radius:14px; font-size:26px; display:flex; align-items:center; justify-content:center; }
.quick-name { font-size:12px; color:#555; }
.invite-banner { display:flex; align-items:center; justify-content:space-between; padding:12px 16px; margin:0 16px; border-radius:10px; color:#fff; font-size:14px; font-weight:600; cursor:pointer; }
.section-title { padding:16px 16px 8px; font-size:16px; font-weight:700; color:#222; }
.loading-wrap { padding:40px; text-align:center; }
.list-end { text-align:center; padding:20px; font-size:12px; color:#ccc; }
</style>