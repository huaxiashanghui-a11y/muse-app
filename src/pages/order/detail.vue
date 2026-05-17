<template>
  <div class="page-no-tab">
    <van-nav-bar title="订单详情" left-arrow @click-left="$router.back()" :border="false" />
    <div v-if="loading" class="loading-wrap"><van-loading color="#FF6B35" size="40" /></div>
    <template v-else-if="order">
      <div class="status-card gradient-orange">
        <div class="status-icon">📦</div>
        <div class="status-text">{{ statusLabel(order.status) }}</div>
      </div>
      <van-cell-group inset class="mt-2">
        <van-cell title="订单号" :value="order.id.slice(0,8).toUpperCase()" />
        <van-cell title="下单时间" :value="new Date(order.created_at).toLocaleString('zh')" />
        <van-cell title="支付方式" :value="order.pay_method" />
        <van-cell title="配送方式" :value="order.delivery_mode==='delivery'?'外卖配送':'自取'" />
        <van-cell v-if="order.remark" title="备注" :value="order.remark" />
      </van-cell-group>
      <div class="card mt-2">
        <div class="card-title">订单明细</div>
        <div v-for="item in order.items" :key="item.id" class="order-item">
          <span>{{ item.emoji }}</span>
          <span class="flex1">{{ item.name }}</span>
          <span>x{{ item.qty }}</span>
          <span class="price">¥{{ (item.price*item.qty).toFixed(2) }}</span>
        </div>
        <div class="total-row"><span>实付</span><span class="pay-total">¥{{ order.total_amount }}</span></div>
      </div>
    </template>
    <van-empty v-else description="订单不存在" />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { supabase } from '@/lib/supabase'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const auth = useAuthStore()
const loading = ref(true)
const order = ref(null)

function statusLabel(s) {
  const m = { pending_payment:'待付款', delivering:'配送中', completed:'已完成', refunding:'退款中', cancelled:'已取消' }
  return m[s] || s
}

onMounted(async () => {
  const id = route.params.id
  if (auth.isLoggedIn) {
    const { data } = await supabase.from('orders').select('*').eq('id', id).single()
    order.value = data
  }
  if (!order.value) {
    const local = JSON.parse(localStorage.getItem('muse_orders')||'[]')
    order.value = local.find(o => o.id === id) || null
  }
  loading.value = false
})
</script>

<style scoped>
.loading-wrap { padding:60px; text-align:center; }
.status-card { padding:30px; text-align:center; color:#fff; }
.status-icon { font-size:48px; margin-bottom:8px; }
.status-text { font-size:20px; font-weight:700; }
.mt-2 { margin-top:12px; }
.card { background:#fff; margin:12px 16px; border-radius:12px; padding:16px; }
.card-title { font-size:15px; font-weight:600; margin-bottom:12px; }
.order-item { display:flex; align-items:center; gap:8px; padding:8px 0; border-bottom:1px solid #f5f5f5; font-size:14px; }
.flex1 { flex:1; }
.price { color:#FF6B35; font-weight:600; }
.total-row { display:flex; justify-content:space-between; padding:12px 0 0; font-weight:700; }
.pay-total { color:#FF6B35; font-size:18px; }
</style>