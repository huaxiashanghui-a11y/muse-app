<template>
  <div class="page-no-tab">
    <van-nav-bar title="帮助中心" left-arrow @click-left="$router.back()" :border="false" />
    <van-collapse v-model="active">
      <van-collapse-item v-for="faq in faqs" :key="faq.q" :title="faq.q" :name="faq.q">{{ faq.a }}</van-collapse-item>
    </van-collapse>
    <div class="contact-btn mx-3 mt-3">
      <van-button block plain color="#FF6B35" icon="chat-o" @click="showToast('客服功能开发中')">联系客服</van-button>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { showToast } from 'vant'

const active = ref([])
const faqs = [
  { q: '如何下单？', a: '选择商家 → 加入购物车 → 确认订单 → 完成支付，即可下单。' },
  { q: '配送费怎么计算？', a: '配送费根据距离浮动，一般为¥2.5起，可在商家详情页查看。' },
  { q: '如何使用优惠券？', a: '在确认订单页面选择"优惠券"，即可抵扣金额。' },
  { q: '订单取消政策？', a: '商家接单前可免费取消；接单后取消可能产生费用。' },
  { q: '如何成为会员？', a: '在"我的" → "会员中心"中，支付¥199即可开通永久会员。' },
  { q: '积分如何获得？', a: '消费、每日签到、完成任务、邀请好友均可获得积分。' },
  { q: '如何申请退款？', a: '在"我的订单"中找到对应订单，点击"申请退款"。' },
  { q: '邀请好友有什么奖励？', a: '好友注册双方各获50积分；好友完成首单，您获100积分+K200佣金。' },
]
</script>

<style scoped>
.mx-3 { margin: 0 16px; }
.mt-3 { margin-top: 12px; }
.contact-btn { padding-bottom: 24px; }
</style>