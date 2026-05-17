<template>
  <div class="page-no-tab">
    <van-nav-bar title="申请入驻商家" left-arrow @click-left="$router.back()" :border="false" />
    <div class="hero gradient-orange">
      <div class="hero-emoji">🏪</div>
      <div class="hero-title">开店做生意，轻松赚钱</div>
      <div class="hero-sub">Muse平台30,000+活跃用户等您来</div>
    </div>
    <div class="stats-row">
      <div class="stat" v-for="s in stats" :key="s.val"><div class="sv">{{ s.val }}</div><div class="sk">{{ s.key }}</div></div>
    </div>
    <van-form @submit="onApply" class="mt-2">
      <van-cell-group inset>
        <van-field v-model="form.shopName" label="店铺名称" placeholder="请输入店铺名" :rules="[{required:true}]" />
        <van-field v-model="form.category" label="经营类目" placeholder="如：奶茶/炸鸡/便当" :rules="[{required:true}]" />
        <van-field v-model="form.address" label="店铺地址" placeholder="仰光市区具体地址" :rules="[{required:true}]" />
        <van-field v-model="form.phone" label="联系电话" placeholder="商家联系电话" type="tel" :rules="[{required:true}]" />
        <van-field v-model="form.intro" label="店铺介绍" placeholder="简单介绍您的店铺" type="textarea" rows="3" />
      </van-cell-group>
      <div style="padding:24px 16px">
        <van-button block color="#FF6B35" round size="large" native-type="submit" :loading="loading">提交申请</van-button>
      </div>
    </van-form>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { showToast } from 'vant'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const auth = useAuthStore()
const loading = ref(false)
const form = ref({ shopName:'', category:'', address:'', phone:'', intro:'' })

const stats = [
  { val:'30,000+', key:'活跃用户' },
  { val:'0元', key:'入驻费用' },
  { val:'T+1', key:'结算周期' },
]

async function onApply() {
  if (!auth.isLoggedIn) { showToast('请先登录'); router.push('/auth/login'); return }
  loading.value = true
  await new Promise(r => setTimeout(r, 1000))
  loading.value = false
  showToast({ message: '申请已提交！我们将在3个工作日内联系您', type: 'success' })
  router.back()
}
</script>

<style scoped>
.hero { padding:32px 20px; text-align:center; }
.hero-emoji { font-size:60px; margin-bottom:12px; }
.hero-title { font-size:20px; font-weight:800; color:#fff; margin-bottom:6px; }
.hero-sub { font-size:14px; color:rgba(255,255,255,.85); }
.stats-row { display:flex; background:#fff; padding:16px 0; margin-bottom:8px; }
.stat { flex:1; text-align:center; }
.sv { font-size:18px; font-weight:800; color:#FF6B35; }
.sk { font-size:12px; color:#888; margin-top:2px; }
.mt-2 { margin-top:0; }
</style>