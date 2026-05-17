<template>
  <div class="page-no-tab member-page">
    <van-nav-bar title="会员中心" left-arrow @click-left="$router.back()" :border="false" />
    <div class="member-card gradient-orange">
      <div class="mc-top">
        <div class="mc-avatar">{{ auth.avatar }}</div>
        <div class="mc-info">
          <div class="mc-name">{{ auth.nickname }}</div>
          <div class="mc-status">{{ auth.isMember ? '👑 尊享会员' : '普通用户' }}</div>
        </div>
      </div>
      <div class="mc-badge" v-if="auth.isMember">会员</div>
    </div>

    <div class="benefits-grid">
      <div v-for="b in benefits" :key="b.name" class="benefit-item">
        <div class="b-icon">{{ b.icon }}</div>
        <div class="b-name">{{ b.name }}</div>
        <div class="b-desc">{{ b.desc }}</div>
      </div>
    </div>

    <div class="card price-card" v-if="!auth.isMember">
      <div class="price-label">开通永久会员</div>
      <div class="price-val">¥199 <span class="price-orig">¥999</span></div>
      <div class="price-desc">一次付费，永久有效，享受所有会员特权</div>
      <van-button block color="#FF6B35" round size="large" @click="openMember" :loading="loading">立即开通会员</van-button>
    </div>
    <div class="card already-member" v-else>
      <van-icon name="checked" color="#52c41a" size="24" />
      <span>您已是尊享会员，感谢支持！</span>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { showToast, showConfirmDialog } from 'vant'
import { supabase } from '@/lib/supabase'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
const loading = ref(false)

const benefits = [
  { icon: '🚀', name: '免配送费', desc: '每单免配送费' },
  { icon: '💰', name: '专属折扣', desc: '全场9折优惠' },
  { icon: '🎁', name: '月度礼包', desc: '每月专属优惠券' },
  { icon: '⭐', name: '积分加倍', desc: '消费积分x2' },
]

async function openMember() {
  if (!auth.isLoggedIn) { showToast('请先登录'); return }
  await showConfirmDialog({ title: '开通会员', message: '开通永久会员需支付 ¥199，确认开通？', confirmButtonText: '确认支付' })
  loading.value = true
  const { error } = await supabase.from('profiles').update({ is_member: true }).eq('id', auth.userId)
  if (!error) {
    await auth.fetchProfile()
    showToast({ message: '🎉 会员开通成功！', type: 'success' })
  } else {
    showToast('开通失败，请重试')
  }
  loading.value = false
}
</script>

<style scoped>
.member-page { background:#F7F8FA; min-height:100vh; }
.member-card { padding:28px 20px; position:relative; overflow:hidden; }
.mc-top { display:flex; align-items:center; gap:16px; color:#fff; }
.mc-avatar { font-size:48px; width:60px; height:60px; border-radius:50%; background:rgba(255,255,255,.2); display:flex; align-items:center; justify-content:center; }
.mc-name { font-size:18px; font-weight:700; color:#fff; }
.mc-status { font-size:13px; color:rgba(255,255,255,.85); margin-top:2px; }
.mc-badge { position:absolute; top:16px; right:16px; background:rgba(255,255,255,.2); color:#fff; padding:4px 12px; border-radius:20px; font-size:13px; font-weight:600; }
.benefits-grid { display:grid; grid-template-columns:repeat(2,1fr); gap:12px; padding:16px; }
.benefit-item { background:#fff; border-radius:12px; padding:16px; text-align:center; }
.b-icon { font-size:32px; margin-bottom:8px; }
.b-name { font-size:14px; font-weight:600; color:#222; }
.b-desc { font-size:12px; color:#888; margin-top:2px; }
.card { background:#fff; margin:0 16px 16px; border-radius:12px; padding:20px; }
.price-label { font-size:16px; font-weight:600; margin-bottom:8px; }
.price-val { font-size:32px; font-weight:900; color:#FF6B35; margin-bottom:6px; }
.price-orig { font-size:16px; color:#aaa; text-decoration:line-through; font-weight:400; }
.price-desc { font-size:13px; color:#888; margin-bottom:16px; }
.already-member { display:flex; align-items:center; gap:12px; font-size:15px; color:#52c41a; font-weight:600; }
</style>