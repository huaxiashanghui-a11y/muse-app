<template>
  <div class="merchant-card" @click="$router.push(`/merchant/${m.id}`)">
    <div class="logo" :style="m.cover_color ? `background:${m.cover_color}` : ''">
      <span v-if="!m.logo_url">{{ m.emoji || "🏪" }}</span>
      <img v-else :src="m.logo_url" alt="" />
    </div>
    <div class="info">
      <div class="name">{{ m.name }}</div>
      <div class="meta">
        <van-rate :model-value="m.rating" readonly allow-half size="12" color="#FF6B35" void-color="#eee" />
        <span class="rating-num">{{ m.rating }}</span>
        <span class="sales">月售{{ m.monthly_sales }}</span>
        <span class="distance">{{ m.distance }}</span>
      </div>
      <div class="delivery-info">
        <span>{{ m.delivery_time }}分钟</span>
        <span class="sep">·</span>
        <span>起送¥{{ m.min_order }}</span>
        <span class="sep">·</span>
        <span>配送¥{{ m.delivery_fee }}</span>
      </div>
      <div class="tags">
        <van-tag v-for="p in (m.promotions||[])" :key="p" type="danger" size="small" plain class="tag">{{ p }}</van-tag>
      </div>
    </div>
  </div>
</template>

<script setup>
defineProps({ m: Object })
</script>

<style scoped>
.merchant-card { display:flex; gap:12px; padding:16px; background:#fff; cursor:pointer; }
.merchant-card:active { background:#fafafa; }
.logo { width:72px; height:72px; border-radius:10px; background:#fff3ee; display:flex; align-items:center; justify-content:center; font-size:36px; overflow:hidden; flex-shrink:0; }
.logo img { width:100%; height:100%; object-fit:cover; }
.info { flex:1; min-width:0; }
.name { font-size:15px; font-weight:600; color:#222; margin-bottom:4px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.meta { display:flex; align-items:center; gap:6px; margin-bottom:4px; font-size:12px; color:#888; }
.rating-num { color:#FF6B35; font-weight:600; }
.delivery-info { font-size:12px; color:#888; margin-bottom:4px; }
.sep { margin:0 2px; }
.tags { display:flex; flex-wrap:wrap; gap:4px; }
.tag { margin:0; }
</style>