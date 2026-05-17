<template>
  <div>
    <slot />
    <van-tabbar v-model="active" active-color="#FF6B35" inactive-color="#999" :border="true" fixed safe-area-inset-bottom>
      <van-tabbar-item name="home"     icon="home-o"      to="/home">首页</van-tabbar-item>
      <van-tabbar-item name="food"     icon="shop-o"      to="/food">外卖</van-tabbar-item>
      <van-tabbar-item name="activity" icon="gift-o"      to="/activity" :dot="activityStore.hasNew">活动</van-tabbar-item>
      <van-tabbar-item name="shop"     icon="medal-o"     to="/shop">商城</van-tabbar-item>
      <van-tabbar-item name="cart"     icon="cart-o"      to="/cart" :badge="cartCount">购物车</van-tabbar-item>
      <van-tabbar-item name="profile"  icon="contact"     to="/profile">我的</van-tabbar-item>
    </van-tabbar>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useCartStore } from '@/stores/cart'
import { useActivityStore } from '@/stores/activity'

const route = useRoute()
const cartStore = useCartStore()
const activityStore = useActivityStore()
const active = computed(() => route.path.split('/')[1] || 'home')
const cartCount = computed(() => cartStore.count > 99 ? '99+' : (cartStore.count || ''))
</script>