<template>
  <div class="page-no-tab">
    <van-nav-bar title="邀请好友" left-arrow @click-left="$router.back()" :border="false" />
    <div class="invite-hero gradient-green">
      <div class="hero-emoji">👥</div>
      <div class="hero-title">邀请好友，双赢奖励</div>
      <div class="hero-sub">好友注册：双方各 50 积分</div>
      <div class="hero-sub">好友首单：您得 K200 佣金 + 100 积分</div>
    </div>

    <div class="card code-card">
      <div class="code-label">我的邀请码</div>
      <div class="code-val">{{ auth.inviteCode }}</div>
      <van-button color="#FF6B35" round size="small" @click="copyCode">复制邀请码</van-button>
    </div>

    <div class="card">
      <div class="card-title">分享到</div>
      <div class="share-grid">
        <div v-for="c in channels" :key="c.name" class="share-item" @click="share(c)">
          <div class="share-icon" :style="`background:${c.color}`">{{ c.icon }}</div>
          <div class="share-name">{{ c.name }}</div>
        </div>
      </div>
    </div>

    <div class="card">
      <div class="card-title">邀请记录</div>
      <div v-if="loadingRecords" class="loading-wrap"><van-loading color="#FF6B35" /></div>
      <van-empty v-else-if="records.length===0" description="暂无邀请记录" />
      <div v-else class="record-list">
        <div v-for="r in records" :key="r.id" class="record-item">
          <div class="rec-icon">🧑</div>
          <div class="rec-info">
            <div class="rec-name">好友 {{ r.invitee_id?.slice(0,8) }}</div>
            <div class="rec-time">{{ new Date(r.registered_at).toLocaleDateString('zh') }}</div>
          </div>
          <div :class="['rec-status', r.is_activated?'activated':'pending']">
            {{ r.is_activated ? '已激活' : '未首单' }}
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { showToast } from 'vant'
import { supabase } from '@/lib/supabase'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
const records = ref([])
const loadingRecords = ref(true)

const channels = [
  { name: 'Telegram', icon: '✈️', color: '#e3f2fd', url: 'tg://msg?text=' },
  { name: 'Facebook', icon: '📘', color: '#e8f4fd', url: 'https://www.facebook.com/sharer/sharer.php?u=' },
  { name: 'Viber',    icon: '💬', color: '#ede7f6', url: 'viber://forward?text=' },
  { name: '复制链接', icon: '🔗', color: '#e8f5e9', url: '' },
  { name: '微信',    icon: '💚', color: '#e8f5e9', url: '' },
  { name: 'Twitter', icon: '🐦', color: '#e3f2fd', url: '' },
]

function copyCode() {
  const text = `我在Muse外卖找到超棒的外卖！用我的邀请码 ${auth.inviteCode} 注册，双方各获50积分！`
  navigator.clipboard.writeText(text).then(() => showToast('已复制邀请链接'))
}

function share(c) {
  if (c.name === '复制链接') { copyCode(); return }
  const text = encodeURIComponent(`Muse外卖 邀请码:${auth.inviteCode}`)
  if (c.url) window.open(c.url + text)
  else showToast('分享功能开发中')
}

onMounted(async () => {
  if (!auth.isLoggedIn) { loadingRecords.value = false; return }
  const { data } = await supabase.from('invite_records').select('*').eq('inviter_id', auth.userId).order('registered_at', { ascending: false })
  records.value = data || []
  loadingRecords.value = false
})
</script>

<style scoped>
.invite-hero { padding:32px 20px; text-align:center; color:#fff; }
.hero-emoji { font-size:60px; margin-bottom:12px; }
.hero-title { font-size:20px; font-weight:800; margin-bottom:8px; }
.hero-sub { font-size:14px; opacity:.9; margin-bottom:4px; }
.card { background:#fff; margin:12px 16px; border-radius:12px; padding:16px; }
.card-title { font-size:15px; font-weight:600; margin-bottom:12px; }
.code-card { text-align:center; }
.code-label { font-size:13px; color:#888; margin-bottom:6px; }
.code-val { font-size:28px; font-weight:900; color:#FF6B35; letter-spacing:4px; margin-bottom:12px; }
.share-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:12px; }
.share-item { text-align:center; cursor:pointer; }
.share-icon { width:52px; height:52px; border-radius:14px; font-size:26px; display:flex; align-items:center; justify-content:center; margin:0 auto 6px; }
.share-name { font-size:12px; color:#555; }
.loading-wrap { padding:30px; text-align:center; }
.record-item { display:flex; align-items:center; gap:12px; padding:10px 0; border-bottom:1px solid #f5f5f5; }
.rec-icon { font-size:28px; }
.rec-name { font-size:14px; font-weight:500; }
.rec-time { font-size:12px; color:#aaa; }
.rec-info { flex:1; }
.rec-status { font-size:13px; font-weight:600; }
.rec-status.activated { color:#52c41a; }
.rec-status.pending { color:#aaa; }
</style>