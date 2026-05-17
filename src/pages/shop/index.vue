<template>
  <tab-layout>
    <div class="page">
      <van-nav-bar title="积分商城" :border="false" />
      <div class="pts-card gradient-purple" @click="$router.push('/points')">
        <div class="pts-label">我的积分</div>
        <div class="pts-value">{{ auth.points }}</div>
        <div class="pts-sub">去赚更多积分 →</div>
      </div>
      <div v-if="loading" class="loading-wrap"><van-loading color="#FF6B35" /></div>
      <template v-else>
        <div v-for="(items, sec) in sections" :key="sec">
          <div class="section-title">{{ sec }}</div>
          <div class="goods-grid">
            <div v-for="g in items" :key="g.id" class="goods-card" @click="confirm(g)">
              <div class="goods-emoji">{{ g.emoji }}</div>
              <div class="goods-name">{{ g.name }}</div>
              <div class="goods-market" v-if="g.market_price">市价¥{{ g.market_price }}</div>
              <div class="goods-pts">{{ g.pts_required }} 积分</div>
            </div>
          </div>
        </div>
      </template>

      <van-dialog v-model:show="dlgShow" :title="`兑换 ${dlgItem?.name}`" show-cancel-button @confirm="doRedeem">
        <div class="dlg-body">
          <div class="dlg-emoji">{{ dlgItem?.emoji }}</div>
          <div>需要 <b style="color:#FF6B35">{{ dlgItem?.pts_required }}</b> 积分</div>
          <div style="color:#aaa;font-size:13px">您当前积分：{{ auth.points }}</div>
        </div>
      </van-dialog>
    </div>
  </tab-layout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { showToast } from 'vant'
import { supabase } from '@/lib/supabase'
import { useAuthStore } from '@/stores/auth'
import TabLayout from '@/components/layout/TabLayout.vue'

const auth = useAuthStore()
const loading = ref(true)
const goods = ref([])
const dlgShow = ref(false)
const dlgItem = ref(null)

const sections = computed(() => {
  const m = {}
  goods.value.forEach(g => { if (!m[g.section]) m[g.section] = []; m[g.section].push(g) })
  return m
})

function confirm(g) {
  if (!auth.isLoggedIn) { showToast('请先登录'); return }
  dlgItem.value = g; dlgShow.value = true
}

async function doRedeem() {
  const g = dlgItem.value
  if (auth.points < g.pts_required) { showToast('积分不足'); return }
  const { error } = await supabase.from('redeem_orders').insert({ user_id: auth.userId, goods_id: g.id, pts_used: g.pts_required })
  if (error) { showToast('兑换失败'); return }
  await auth.addPoints(-g.pts_required, 'redeem', `兑换${g.name}`)
  showToast('兑换成功！')
}

onMounted(async () => {
  const { data } = await supabase.from('shop_goods').select('*').eq('is_active', true).order('sort_order')
  goods.value = data || []
  loading.value = false
})
</script>

<style scoped>
.pts-card { margin:16px; padding:24px 20px; border-radius:14px; color:#fff; cursor:pointer; }
.pts-label { font-size:13px; opacity:.8; }
.pts-value { font-size:40px; font-weight:900; margin:4px 0; }
.pts-sub { font-size:13px; opacity:.8; }
.section-title { padding:16px 16px 8px; font-size:15px; font-weight:700; color:#222; }
.goods-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:10px; padding:0 16px 16px; }
.goods-card { background:#fff; border-radius:10px; padding:14px 8px; text-align:center; cursor:pointer; }
.goods-card:active { opacity:.8; }
.goods-emoji { font-size:34px; margin-bottom:6px; }
.goods-name { font-size:13px; font-weight:600; color:#333; }
.goods-market { font-size:11px; color:#aaa; text-decoration:line-through; margin-top:2px; }
.goods-pts { font-size:13px; color:#FF6B35; font-weight:700; margin-top:4px; }
.loading-wrap { padding:60px; text-align:center; }
.dlg-body { padding:20px; text-align:center; display:flex; flex-direction:column; gap:8px; align-items:center; }
.dlg-emoji { font-size:48px; }
</style>