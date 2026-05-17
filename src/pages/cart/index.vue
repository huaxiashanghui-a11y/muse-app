<template>
  <tab-layout>
    <div class="page">
      <van-nav-bar title="购物车" :border="false" />
      <div v-if="cart.isEmpty" class="empty-cart">
        <van-empty image="cart" description="购物车空空如也" />
        <van-button color="#FF6B35" round @click="$router.push('/food')">去点餐</van-button>
      </div>
      <template v-else>
        <van-swipe-cell v-for="item in cart.items" :key="item.id">
          <div class="cart-item">
            <div class="item-emoji">{{ item.emoji }}</div>
            <div class="item-info">
              <div class="item-name">{{ item.name }}</div>
              <div class="item-price">¥{{ item.price }}</div>
            </div>
            <van-stepper v-model="item.qty" min="0" @change="(v)=>onQtyChange(item,v)" />
          </div>
          <template #right>
            <van-button square type="danger" text="删除" @click="cart.removeItem(item.id)" style="height:100%" />
          </template>
        </van-swipe-cell>

        <div class="cart-footer">
          <div class="total-row">
            <span>合计</span>
            <span class="total-price">¥{{ cart.total.toFixed(2) }}</span>
          </div>
          <van-button block color="#FF6B35" round size="large" @click="$router.push('/order/confirm')">去结算 ({{ cart.count }}件)</van-button>
        </div>
      </template>
    </div>
  </tab-layout>
</template>

<script setup>
import { useCartStore } from '@/stores/cart'
import TabLayout from '@/components/layout/TabLayout.vue'

const cart = useCartStore()

function onQtyChange(item, v) {
  if (v === 0) cart.removeItem(item.id)
  else item.qty = v
  cart._save()
}
</script>

<style scoped>
.empty-cart { display:flex; flex-direction:column; align-items:center; gap:16px; padding-top:40px; }
.cart-item { display:flex; align-items:center; gap:12px; padding:14px 16px; background:#fff; }
.item-emoji { font-size:32px; }
.item-info { flex:1; }
.item-name { font-size:14px; font-weight:500; }
.item-price { font-size:14px; color:#FF6B35; font-weight:600; margin-top:2px; }
.cart-footer { position:sticky; bottom:56px; background:#fff; padding:16px; border-top:1px solid #f0f0f0; }
.total-row { display:flex; justify-content:space-between; margin-bottom:12px; font-size:15px; font-weight:600; }
.total-price { color:#FF6B35; font-size:18px; }
</style>