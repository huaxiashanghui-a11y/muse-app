<template>
  <div class="page-no-tab rider-page">
    <van-nav-bar title="成为骑手" left-arrow @click-left="$router.back()" :border="false" />
    <div class="hero gradient-orange">
      <div class="hero-emoji">🛵</div>
      <div class="hero-title">加入我们，灵活赚钱</div>
      <div class="hero-sub">优秀骑手月收入最高 K 150,000</div>
    </div>
    <div class="income-cards mx-3">
      <div class="i-card" v-for="s in incomeStats" :key="s.val">
        <div class="i-val">{{ s.val }}</div>
        <div class="i-key">{{ s.key }}</div>
      </div>
    </div>
    <div class="advantages card mx-3 mt-3">
      <div v-for="a in advantages" :key="a.title" class="adv-item">
        <div class="adv-icon">{{ a.icon }}</div>
        <div><div class="adv-title">{{ a.title }}</div><div class="adv-desc">{{ a.desc }}</div></div>
      </div>
    </div>
    <div class="requirements card mx-3 mt-3">
      <div class="req-title">申请条件</div>
      <div v-for="r in requirements" :key="r" class="req-item">✅ {{ r }}</div>
    </div>
    <div class="cta-wrap">
      <van-button block color="#FF6B35" round size="large" @click="onApply">立即申请成为骑手</van-button>
    </div>
  </div>
</template>

<script setup>
import { showToast } from 'vant'
import { useAuthStore } from '@/stores/auth'
import { useRouter } from 'vue-router'

const auth = useAuthStore()
const router = useRouter()

const incomeStats = [
  { val: 'K 150,000', key: '月收入上限' },
  { val: 'K 800', key: '平均每单' },
  { val: '随时', key: '自由上下线' },
]
const advantages = [
  { icon: '🕐', title: '时间自由', desc: '自主安排工作时间，接单收入灵活' },
  { icon: '💰', title: '收入可观', desc: '按单计费，多劳多得，周结到账' },
  { icon: '🛡️', title: '平台保障', desc: '平台意外险保障，配送安全无忧' },
]
const requirements = ['年满18周岁', '有效身份证件', '有交通工具（摩托车/电动车）', '缅甸本地手机号']

function onApply() {
  if (!auth.isLoggedIn) { showToast('请先登录'); router.push('/auth/login'); return }
  showToast('骑手申请已提交，我们将在3个工作日内联系您')
}
</script>

<style scoped>
.rider-page { background: #F7F8FA; min-height: 100vh; padding-bottom: 100px; }
.hero { padding: 32px 20px; text-align: center; }
.hero-emoji { font-size: 64px; margin-bottom: 12px; }
.hero-title { font-size: 24px; font-weight: 800; color: #fff; margin-bottom: 6px; }
.hero-sub { font-size: 14px; color: rgba(255,255,255,0.85); }
.mx-3 { margin-left: 16px; margin-right: 16px; }
.mt-3 { margin-top: 12px; }
.income-cards { display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; margin-top: -16px; }
.i-card { background: #fff; border-radius: 10px; padding: 14px 8px; text-align: center; box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
.i-val { font-size: 16px; font-weight: 800; color: #FF6B35; }
.i-key { font-size: 11px; color: #888; margin-top: 4px; }
.advantages { padding: 16px; border-radius: 12px; }
.adv-item { display: flex; gap: 12px; align-items: flex-start; padding: 10px 0; border-bottom: 1px solid #f5f5f5; }
.adv-item:last-child { border-bottom: none; }
.adv-icon { font-size: 28px; }
.adv-title { font-size: 14px; font-weight: 600; color: #333; }
.adv-desc { font-size: 12px; color: #888; margin-top: 2px; }
.requirements { padding: 16px; border-radius: 12px; }
.req-title { font-size: 15px; font-weight: 600; margin-bottom: 12px; }
.req-item { font-size: 14px; color: #555; padding: 6px 0; }
.cta-wrap { position: fixed; bottom: 0; left: 50%; transform: translateX(-50%); width: 100%; max-width: 480px; padding: 12px 16px; background: #fff; border-top: 1px solid #eee; }
</style>