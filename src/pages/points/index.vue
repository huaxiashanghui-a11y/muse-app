<template>
  <div class="page-no-tab">
    <van-nav-bar title="积分中心" left-arrow @click-left="$router.back()" :border="false" />
    <div class="pts-hero gradient-purple">
      <div class="pts-val">{{ auth.points }}</div>
      <div class="pts-label">当前积分</div>
    </div>
    <div class="section-title">积分流水</div>
    <div v-if="loading" class="loading-wrap"><van-loading color="#FF6B35" /></div>
    <van-empty v-else-if="txs.length===0" description="暂无积分记录" />
    <div v-else class="tx-list">
      <div v-for="t in txs" :key="t.id" class="tx-item">
        <div class="tx-type">{{ typeLabel(t.type) }}</div>
        <div class="tx-desc">{{ t.description }}</div>
        <div :class="['tx-pts', t.points>0?'plus':'minus']">{{ t.points>0?'+':'' }}{{ t.points }}</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/lib/supabase'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
const loading = ref(true)
const txs = ref([])

function typeLabel(t) {
  const m = { signin:'签到', order:'订单', redeem:'兑换', invite:'邀请', task:'任务' }
  return m[t] || t
}

onMounted(async () => {
  if (!auth.isLoggedIn) { loading.value = false; return }
  const { data } = await supabase.from('point_transactions').select('*').eq('user_id', auth.userId).order('created_at', { ascending: false }).limit(50)
  txs.value = data || []
  loading.value = false
})
</script>

<style scoped>
.pts-hero { padding:40px; text-align:center; color:#fff; }
.pts-val { font-size:56px; font-weight:900; }
.pts-label { font-size:14px; opacity:.8; margin-top:4px; }
.section-title { padding:16px 16px 8px; font-size:15px; font-weight:600; }
.loading-wrap { padding:60px; text-align:center; }
.tx-list { padding:0 16px; }
.tx-item { display:flex; align-items:center; gap:10px; padding:12px 0; border-bottom:1px solid #f5f5f5; }
.tx-type { font-size:13px; font-weight:600; color:#555; width:40px; }
.tx-desc { flex:1; font-size:13px; color:#888; }
.tx-pts { font-size:15px; font-weight:700; }
.tx-pts.plus { color:#52c41a; }
.tx-pts.minus { color:#FF6B35; }
</style>