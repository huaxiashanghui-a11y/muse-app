<template>
  <tab-layout>
    <div class="page" @vue:mounted="actStore.markRead()">
      <van-nav-bar title="活动中心" :border="false" />
      <van-tabs v-model:active="tab" color="#FF6B35" title-active-color="#FF6B35" sticky>
        <!-- Flash sale -->
        <van-tab title="秒杀" name="flash">
          <div class="flash-header">
            <span class="flash-title">⚡ 限时秒杀</span>
            <van-count-down :time="flashTime" format="HH:mm:ss" class="flash-count" />
          </div>
          <div v-if="loadingFlash" class="loading-wrap"><van-loading color="#FF6B35" /></div>
          <div class="flash-grid" v-else>
            <div v-for="f in flashSales" :key="f.id" class="flash-item" @click="$router.push(`/merchant/${f.merchant_id}`)">
              <div class="flash-emoji">{{ f.emoji }}</div>
              <div class="flash-name">{{ f.name }}</div>
              <div class="flash-price">¥{{ f.flash_price }}</div>
              <div class="flash-orig">¥{{ f.original_price }}</div>
              <van-button size="mini" color="#FF6B35" round block>抢购</van-button>
            </div>
          </div>
        </van-tab>

        <!-- Coupons -->
        <van-tab title="优惠券" name="coupon">
          <div v-if="loadingCoupons" class="loading-wrap"><van-loading color="#FF6B35" /></div>
          <div v-else class="coupon-list">
            <div v-for="c in coupons" :key="c.id" class="coupon-card">
              <div class="coupon-left">
                <div class="coupon-val">{{ c.type==='cash' ? `¥${c.value}` : `${c.value*10}折` }}</div>
                <div class="coupon-min">满¥{{ c.min_order }}可用</div>
              </div>
              <div class="coupon-right">
                <div class="coupon-name">{{ c.name }}</div>
                <div class="coupon-exp">{{ c.expire_days }}天有效</div>
                <van-button size="mini" color="#FF6B35" round @click="claimCoupon(c)" :disabled="claimedIds.has(c.id)">
                  {{ claimedIds.has(c.id) ? '已领取' : '立即领取' }}
                </van-button>
              </div>
            </div>
          </div>
        </van-tab>

        <!-- Tasks -->
        <van-tab title="积分任务" name="tasks">
          <div class="task-list">
            <div v-for="t in tasks" :key="t.id" class="task-item">
              <div class="task-icon">{{ t.icon }}</div>
              <div class="task-info">
                <div class="task-name">{{ t.name }}</div>
                <div class="task-desc">+{{ t.pts }}积分</div>
              </div>
              <van-button size="mini" :color="t.done?'#aaa':'#FF6B35'" round @click="doTask(t)" :disabled="t.done">
                {{ t.done ? '已完成' : '去完成' }}
              </van-button>
            </div>
          </div>
        </van-tab>

        <!-- Invite -->
        <van-tab title="邀请" name="invite">
          <div class="invite-card gradient-green">
            <div class="inv-title">👥 邀请好友，双方得奖励</div>
            <div class="inv-desc">好友注册：双方各获 50 积分</div>
            <div class="inv-desc">好友首单：您获 K200 佣金 + 100 积分</div>
            <van-button color="#fff" plain round block style="margin-top:16px;color:#11998e" @click="$router.push('/invite')">立即邀请</van-button>
          </div>
        </van-tab>
      </van-tabs>
    </div>
  </tab-layout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { showToast } from 'vant'
import { supabase } from '@/lib/supabase'
import { useAuthStore } from '@/stores/auth'
import { useActivityStore } from '@/stores/activity'
import TabLayout from '@/components/layout/TabLayout.vue'

const auth = useAuthStore()
const actStore = useActivityStore()
const tab = ref('flash')
const loadingFlash = ref(true)
const loadingCoupons = ref(true)
const flashSales = ref([])
const coupons = ref([])
const claimedIds = ref(new Set())
const flashTime = ref(3 * 60 * 60 * 1000)

const tasks = ref([
  { id:'signin', icon:'📅', name:'每日签到', pts:10, done: localStorage.getItem('muse_signin_'+new Date().toDateString()) === '1' },
  { id:'share', icon:'📤', name:'分享好友', pts:5, done: false },
  { id:'review', icon:'⭐', name:'评价订单', pts:20, done: false },
])

async function fetchFlash() {
  loadingFlash.value = true
  const { data } = await supabase.from('flash_sales').select('*').eq('is_active', true).limit(12)
  flashSales.value = data || []
  loadingFlash.value = false
}

async function fetchCoupons() {
  loadingCoupons.value = true
  const { data } = await supabase.from('coupons').select('*').eq('is_public', true).order('sort_order')
  coupons.value = data || []
  if (auth.isLoggedIn) {
    const { data: uc } = await supabase.from('user_coupons').select('coupon_id').eq('user_id', auth.userId)
    if (uc) uc.forEach(u => claimedIds.value.add(u.coupon_id))
  }
  loadingCoupons.value = false
}

async function claimCoupon(c) {
  if (!auth.isLoggedIn) { showToast('请先登录'); return }
  const exp = new Date(); exp.setDate(exp.getDate() + c.expire_days)
  const { error } = await supabase.from('user_coupons').insert({ user_id: auth.userId, coupon_id: c.id, expires_at: exp.toISOString() })
  if (!error) { claimedIds.value.add(c.id); showToast('领取成功！') }
  else showToast('已领取过啦')
}

async function doTask(t) {
  if (!auth.isLoggedIn) { showToast('请先登录'); return }
  if (t.id === 'signin') {
    await auth.addPoints(t.pts, 'signin', '每日签到')
    localStorage.setItem('muse_signin_'+new Date().toDateString(), '1')
    t.done = true
    showToast(`签到成功！+${t.pts}积分`)
  } else {
    showToast('任务功能开发中')
  }
}

onMounted(() => { fetchFlash(); fetchCoupons() })
</script>

<style scoped>
.flash-header { display:flex; align-items:center; justify-content:space-between; padding:12px 16px; background:#fff3ee; }
.flash-title { font-size:16px; font-weight:700; color:#FF6B35; }
.flash-count { font-size:14px; color:#FF6B35; font-weight:600; }
.flash-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:10px; padding:12px 16px; }
.flash-item { background:#fff; border-radius:10px; padding:12px 8px; text-align:center; }
.flash-emoji { font-size:32px; }
.flash-name { font-size:13px; color:#333; margin:4px 0; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.flash-price { font-size:16px; font-weight:700; color:#FF6B35; }
.flash-orig { font-size:11px; color:#aaa; text-decoration:line-through; margin-bottom:6px; }
.coupon-list { padding:12px 16px; display:flex; flex-direction:column; gap:12px; }
.coupon-card { display:flex; border-radius:10px; overflow:hidden; box-shadow:0 2px 8px rgba(0,0,0,.08); }
.coupon-left { background:#FF6B35; color:#fff; width:90px; display:flex; flex-direction:column; align-items:center; justify-content:center; padding:16px 8px; }
.coupon-val { font-size:22px; font-weight:800; }
.coupon-min { font-size:11px; opacity:.85; }
.coupon-right { flex:1; background:#fff; padding:12px 16px; display:flex; flex-direction:column; justify-content:space-between; }
.coupon-name { font-size:14px; font-weight:600; }
.coupon-exp { font-size:12px; color:#aaa; }
.task-list { padding:12px 16px; }
.task-item { display:flex; align-items:center; gap:12px; padding:14px 0; border-bottom:1px solid #f5f5f5; }
.task-icon { font-size:28px; }
.task-name { font-size:14px; font-weight:500; }
.task-desc { font-size:12px; color:#FF6B35; }
.task-info { flex:1; }
.invite-card { margin:16px; padding:20px; border-radius:14px; color:#fff; }
.inv-title { font-size:18px; font-weight:800; margin-bottom:10px; }
.inv-desc { font-size:14px; opacity:.9; margin-bottom:4px; }
.loading-wrap { padding:60px; text-align:center; }
</style>