<template>
  <div class="page-no-tab">
    <van-nav-bar title="确认订单" left-arrow @click-left="$router.back()" :border="false" />
    <div v-if="cart.isEmpty" class="empty-tip">购物车为空</div>
    <template v-else>
      <!-- Delivery mode -->
      <div class="card mode-row">
        <van-button-group>
          <van-button :type="mode==='delivery'?'primary':'default'" size="small" @click="mode='delivery'" color="#FF6B35">外卖配送</van-button>
          <van-button :type="mode==='pickup'?'primary':'default'" size="small" @click="mode='pickup'" color="#FF6B35">自取</van-button>
        </van-button-group>
      </div>

      <!-- Address -->
      <div class="card addr-card" v-if="mode==='delivery'" @click="$router.push('/address?pick=1')">
        <van-icon name="location-o" color="#FF6B35" size="20" />
        <div v-if="defaultAddr" class="addr-info">
          <div class="addr-name">{{ defaultAddr.name }} {{ defaultAddr.phone }}</div>
          <div class="addr-detail">{{ defaultAddr.detail }}</div>
        </div>
        <div v-else class="addr-add">添加收货地址 ›</div>
      </div>

      <!-- Items -->
      <div class="card">
        <div class="card-title">订单明细</div>
        <div v-for="item in cart.items" :key="item.id" class="order-item">
          <span class="oi-emoji">{{ item.emoji }}</span>
          <span class="oi-name">{{ item.name }}</span>
          <span class="oi-qty">x{{ item.qty }}</span>
          <span class="oi-price">¥{{ (item.price * item.qty).toFixed(2) }}</span>
        </div>
      </div>

      <!-- Fee breakdown -->
      <div class="card fee-card">
        <div class="fee-row"><span>商品合计</span><span>¥{{ cart.total.toFixed(2) }}</span></div>
        <div class="fee-row" v-if="mode==='delivery'"><span>配送费</span><span>¥2.50</span></div>
        <div class="fee-row"><span>打包费</span><span>¥4.00</span></div>
        <div class="fee-row discount" v-if="discountAmt>0"><span>满减优惠</span><span>-¥{{ discountAmt.toFixed(2) }}</span></div>
        <div class="fee-row discount" v-if="usePts"><span>积分抵扣</span><span>-¥{{ ptsDeduct.toFixed(2) }}</span></div>
        <div class="fee-row total-row"><span>实付金额</span><span class="pay-total">¥{{ payTotal.toFixed(2) }}</span></div>
      </div>

      <!-- Options -->
      <div class="card">
        <van-field v-model="remark" label="备注" placeholder="口味、忌口等（30字内）" :maxlength="30" />
        <van-cell title="使用积分" :value="`可用 ${auth.points} 分`">
          <template #right-icon><van-switch v-model="usePts" size="20" active-color="#FF6B35" /></template>
        </van-cell>
        <van-cell title="支付方式" :value="payMethod" is-link @click="showPayPicker=true" />
      </div>

      <div class="submit-bar">
        <div class="pay-amount">¥{{ payTotal.toFixed(2) }}</div>
        <van-button color="#FF6B35" round size="large" :loading="submitting" @click="submit">提交订单</van-button>
      </div>
    </template>

    <van-action-sheet v-model:show="showPayPicker" title="选择支付方式" :actions="payOptions" @select="onSelectPay" />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { showToast } from 'vant'
import { supabase } from '@/lib/supabase'
import { useCartStore } from '@/stores/cart'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const cart = useCartStore()
const auth = useAuthStore()
const mode = ref('delivery')
const remark = ref('')
const usePts = ref(false)
const submitting = ref(false)
const showPayPicker = ref(false)
const payMethod = ref('微信支付')
const defaultAddr = ref(null)

const payOptions = [
  { name: '微信支付', value: 'wechat' },
  { name: '支付宝', value: 'alipay' },
  { name: 'KPay', value: 'kpay' },
  { name: '货到付款', value: 'cod' },
]

function onSelectPay(a) { payMethod.value = a.name; showPayPicker.value = false }

const discountAmt = computed(() => {
  const t = cart.total
  if (t >= 72) return 15
  if (t >= 38) return 8
  if (t >= 25) return 3
  return 0
})

const ptsDeduct = computed(() => {
  if (!usePts.value || !auth.isLoggedIn) return 0
  const maxDeduct = cart.total * 0.5
  return Math.min(auth.points / 100, maxDeduct)
})

const deliveryFee = computed(() => mode.value === 'delivery' ? 2.5 : 0)
const payTotal = computed(() => Math.max(0, cart.total + deliveryFee.value + 4 - discountAmt.value - ptsDeduct.value))

async function submit() {
  if (!auth.isLoggedIn) { showToast('请先登录'); router.push('/auth/login'); return }
  if (mode.value === 'delivery' && !defaultAddr.value) { showToast('请添加收货地址'); return }
  submitting.value = true
  const order = {
    user_id: auth.userId,
    merchant_id: cart.merchantId,
    items: cart.items,
    total_amount: payTotal.value,
    delivery_fee: deliveryFee.value,
    discount_amount: discountAmt.value,
    points_used: usePts.value ? Math.floor(ptsDeduct.value * 100) : 0,
    pay_method: payMethod.value,
    delivery_mode: mode.value,
    address_id: defaultAddr.value?.id,
    remark: remark.value,
    status: 'pending_payment',
  }
  const { data, error } = await supabase.from('orders').insert(order).select().single()
  if (error) {
    const local = JSON.parse(localStorage.getItem('muse_orders')||'[]')
    local.unshift({ ...order, id: Date.now().toString(), created_at: new Date().toISOString() })
    localStorage.setItem('muse_orders', JSON.stringify(local))
  }
  if (usePts.value && ptsDeduct.value > 0) {
    await auth.addPoints(-Math.floor(ptsDeduct.value * 100), 'order', '积分抵扣')
  }
  cart.clear()
  submitting.value = false
  showToast({ message: '下单成功！', type: 'success' })
  router.replace('/order/list')
}

onMounted(async () => {
  if (!auth.isLoggedIn) return
  const { data } = await supabase.from('addresses').select('*').eq('user_id', auth.userId).eq('is_default', true).single()
  defaultAddr.value = data
})
</script>

<style scoped>
.card { background:#fff; margin:8px 16px; border-radius:12px; padding:16px; }
.card-title { font-size:15px; font-weight:600; margin-bottom:12px; }
.mode-row { display:flex; justify-content:center; }
.addr-card { display:flex; align-items:center; gap:12px; cursor:pointer; }
.addr-info { flex:1; }
.addr-name { font-size:14px; font-weight:600; }
.addr-detail { font-size:13px; color:#888; margin-top:2px; }
.addr-add { color:#aaa; font-size:14px; }
.order-item { display:flex; align-items:center; gap:8px; padding:8px 0; border-bottom:1px solid #f5f5f5; }
.oi-emoji { font-size:24px; }
.oi-name { flex:1; font-size:14px; }
.oi-qty { color:#888; font-size:13px; }
.oi-price { color:#FF6B35; font-weight:600; }
.fee-card { }
.fee-row { display:flex; justify-content:space-between; padding:6px 0; font-size:14px; color:#555; }
.discount { color:#FF6B35; }
.total-row { border-top:1px solid #f0f0f0; margin-top:6px; padding-top:12px; font-weight:700; color:#222; }
.pay-total { color:#FF6B35; font-size:18px; }
.empty-tip { text-align:center; padding:60px; color:#aaa; }
.submit-bar { position:fixed; bottom:0; left:50%; transform:translateX(-50%); width:100%; max-width:480px; padding:12px 16px; background:#fff; border-top:1px solid #eee; display:flex; align-items:center; gap:12px; }
.pay-amount { font-size:20px; font-weight:800; color:#FF6B35; }
</style>