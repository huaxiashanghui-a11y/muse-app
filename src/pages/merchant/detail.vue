<template>
  <div class="page-no-tab">
    <van-nav-bar :title="merchant?.name||'商家'" left-arrow @click-left="$router.back()" :border="false" />

    <div v-if="loading" class="loading-wrap"><van-loading color="#FF6B35" size="40" /></div>
    <template v-else-if="merchant">
      <!-- Cover -->
      <div class="cover" :style="merchant.cover_color?`background:${merchant.cover_color}`:''">
        <div class="cover-emoji">{{ merchant.emoji }}</div>
      </div>
      <!-- Info -->
      <div class="merchant-info card">
        <div class="m-name">{{ merchant.name }}</div>
        <div class="m-meta">
          <van-rate :model-value="merchant.rating" readonly allow-half size="14" color="#FF6B35" void-color="#eee" />
          <span>{{ merchant.rating }}</span> · 月售{{ merchant.monthly_sales }}
        </div>
        <div class="m-meta">🕐 {{ merchant.delivery_time }}分钟 · 🏠 起送¥{{ merchant.min_order }} · 配送¥{{ merchant.delivery_fee }}</div>
        <div class="m-tags">
          <van-tag v-for="p in merchant.promotions" :key="p" type="danger" plain>{{ p }}</van-tag>
        </div>
      </div>

      <!-- Tabs -->
      <van-tabs v-model:active="activeTab" color="#FF6B35" title-active-color="#FF6B35" sticky :offset-top="46">
        <!-- Order tab -->
        <van-tab title="点餐" name="order">
          <div v-if="loadingProducts" class="loading-wrap"><van-loading color="#FF6B35" /></div>
          <div class="product-list" v-else>
            <product-card v-for="p in products" :key="p.id" :p="p" @add="addToCart(p)" />
          </div>
        </van-tab>

        <!-- Reviews tab -->
        <van-tab title="评价" name="reviews">
          <div v-if="loadingReviews" class="loading-wrap"><van-loading color="#FF6B35" /></div>
          <div v-else-if="reviews.length===0" class="empty-tip">暂无评价</div>
          <div v-else class="review-list">
            <div v-for="r in reviews" :key="r.id" class="review-item">
              <div class="review-head">
                <span class="r-avatar">{{ r.profiles?.avatar||'🧑' }}</span>
                <span class="r-name">{{ r.profiles?.nickname||'用户' }}</span>
                <van-rate :model-value="r.rating" readonly size="12" color="#FF6B35" class="ml-auto" />
              </div>
              <div class="r-content">{{ r.content }}</div>
            </div>
          </div>
        </van-tab>

        <!-- Info tab -->
        <van-tab title="商家" name="info">
          <van-cell-group inset class="mt-2">
            <van-cell title="地址" :value="merchant.address||'仰光市区'" />
            <van-cell title="营业时间" :value="merchant.business_hours" />
            <van-cell title="配送范围" :value="merchant.delivery_range" />
          </van-cell-group>
        </van-tab>
      </van-tabs>
    </template>

    <!-- Cart bar -->
    <div class="cart-bar" v-if="cart.count>0" @click="$router.push('/cart')">
      <div class="cart-badge">{{ cart.count }}</div>
      <span>已选 {{ cart.count }} 件</span>
      <span class="cart-total">¥{{ cart.total.toFixed(2) }}</span>
      <van-button size="small" color="#FF6B35" round @click.stop="$router.push('/order/confirm')">去结算</van-button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { showToast } from 'vant'
import { supabase } from '@/lib/supabase'
import { useCartStore } from '@/stores/cart'
import ProductCard from '@/components/home/ProductCard.vue'

const route = useRoute()
const cart = useCartStore()
const mid = route.params.id
const loading = ref(true)
const loadingProducts = ref(true)
const loadingReviews = ref(true)
const merchant = ref(null)
const products = ref([])
const reviews = ref([])
const activeTab = ref('order')

function addToCart(p) {
  cart.addItem({ id: p.id, name: p.name, price: p.price, emoji: p.emoji }, mid)
  showToast({ message: '已加入购物车', position: 'bottom' })
}

onMounted(async () => {
  const { data: m } = await supabase.from('merchants').select('*').eq('id', mid).single()
  merchant.value = m
  loading.value = false

  const [{ data: ps }, { data: rs }] = await Promise.all([
    supabase.from('products').select('*').eq('merchant_id', mid).eq('is_active', true).order('sort_order'),
    supabase.from('reviews').select('*, profiles(nickname, avatar)').eq('merchant_id', mid).order('created_at', { ascending: false }).limit(20),
  ])
  products.value = ps || []
  loadingProducts.value = false
  reviews.value = rs || []
  loadingReviews.value = false
})
</script>

<style scoped>
.cover { height:160px; display:flex; align-items:center; justify-content:center; background:#fff3ee; }
.cover-emoji { font-size:80px; }
.merchant-info { margin:12px 16px; padding:16px; border-radius:12px; }
.m-name { font-size:18px; font-weight:800; margin-bottom:6px; }
.m-meta { font-size:13px; color:#666; display:flex; align-items:center; gap:6px; margin-bottom:4px; }
.m-tags { display:flex; flex-wrap:wrap; gap:6px; margin-top:6px; }
.ml-auto { margin-left:auto; }
.product-list { padding:0 16px; }
.review-list { padding:0 16px; }
.review-item { padding:14px 0; border-bottom:1px solid #f5f5f5; }
.review-head { display:flex; align-items:center; gap:8px; margin-bottom:8px; }
.r-avatar { font-size:24px; }
.r-name { font-size:14px; font-weight:500; }
.r-content { font-size:13px; color:#555; }
.empty-tip { text-align:center; padding:40px; color:#aaa; }
.loading-wrap { padding:60px; text-align:center; }
.mt-2 { margin-top:12px; }
.cart-bar { position:fixed; bottom:0; left:50%; transform:translateX(-50%); width:100%; max-width:480px; display:flex; align-items:center; gap:12px; padding:10px 16px; background:#222; border-radius:16px 16px 0 0; z-index:100; cursor:pointer; }
.cart-badge { background:#FF6B35; color:#fff; border-radius:50%; width:24px; height:24px; line-height:24px; text-align:center; font-size:13px; font-weight:700; }
.cart-bar span { color:#fff; font-size:14px; }
.cart-total { margin-left:auto; font-size:16px; font-weight:700; color:#FF6B35; }
</style>