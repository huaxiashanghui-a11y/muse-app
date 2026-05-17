<template>
  <div class="page-no-tab">
    <van-nav-bar title="我的订单" left-arrow @click-left="$router.back()" :border="false" />
    <van-tabs v-model:active="tab" color="#FF6B35" title-active-color="#FF6B35" sticky :offset-top="46">
      <van-tab v-for="s in statuses" :key="s.val" :title="s.label" :name="s.val">
        <div v-if="loading" class="loading-wrap"><van-loading color="#FF6B35" /></div>
        <van-empty v-else-if="filtered.length===0" description="暂无订单" />
        <div v-else class="order-list">
          <div v-for="o in filtered" :key="o.id" class="order-card" @click="$router.push(`/order/${o.id}`)">
            <div class="o-head">
              <span class="o-time">{{ fmtDate(o.created_at) }}</span>
              <span :class="['o-status', o.status]">{{ statusLabel(o.status) }}</span>
            </div>
            <div class="o-items">
              <span v-for="item in (o.items||[]).slice(0,3)" :key="item.id" class="o-emoji">{{ item.emoji }}</span>
              <span v-if="(o.items||[]).length>3" class="o-more">+{{ o.items.length-3 }}</span>
            </div>
            <div class="o-footer">
              <span class="o-total">¥{{ o.total_amount }}</span>
              <van-button v-if="o.status==='pending_payment'" size="mini" color="#FF6B35" round>去付款</van-button>
            </div>
          </div>
        </div>
      </van-tab>
    </van-tabs>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { supabase } from '@/lib/supabase'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
const tab = ref('all')
const loading = ref(true)
const orders = ref([])

const statuses = [
  { val: 'all', label: '全部' },
  { val: 'pending_payment', label: '待付款' },
  { val: 'delivering', label: '配送中' },
  { val: 'completed', label: '已完成' },
  { val: 'refunding', label: '退款' },
]

const filtered = computed(() => tab.value === 'all' ? orders.value : orders.value.filter(o => o.status === tab.value))

function statusLabel(s) {
  const m = { pending_payment:'待付款', delivering:'配送中', completed:'已完成', refunding:'退款中', cancelled:'已取消' }
  return m[s] || s
}

function fmtDate(d) {
  return new Date(d).toLocaleString('zh', { month:'2-digit', day:'2-digit', hour:'2-digit', minute:'2-digit' })
}

async function fetchOrders() {
  loading.value = true
  if (!auth.isLoggedIn) {
    const local = JSON.parse(localStorage.getItem('muse_orders')||'[]')
    orders.value = local
  } else {
    const { data } = await supabase.from('orders').select('*').eq('user_id', auth.userId).order('created_at', { ascending: false })
    const local = JSON.parse(localStorage.getItem('muse_orders')||'[]')
    orders.value = [...(data||[]), ...local]
  }
  loading.value = false
}

onMounted(fetchOrders)
</script>

<style scoped>
.loading-wrap { padding:60px; text-align:center; }
.order-list { padding:12px 16px; display:flex; flex-direction:column; gap:12px; }
.order-card { background:#fff; border-radius:12px; padding:14px; cursor:pointer; }
.o-head { display:flex; justify-content:space-between; margin-bottom:10px; font-size:13px; color:#888; }
.o-status { font-weight:600; }
.o-status.pending_payment { color:#FF6B35; }
.o-status.completed { color:#52c41a; }
.o-items { display:flex; align-items:center; gap:4px; margin-bottom:10px; }
.o-emoji { font-size:28px; }
.o-more { font-size:12px; color:#aaa; }
.o-footer { display:flex; align-items:center; justify-content:space-between; }
.o-total { font-size:16px; font-weight:700; color:#222; }
</style>