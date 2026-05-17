<template>
  <div class="product-card">
    <div class="img-wrap">
      <span v-if="!p.image_url" class="emoji">{{ p.emoji || "🍜" }}</span>
      <img v-else :src="p.image_url" alt="" />
      <van-tag v-if="p.label" type="danger" class="label-tag">{{ p.label }}</van-tag>
    </div>
    <div class="detail">
      <div class="pname">{{ p.name }}</div>
      <div class="spec" v-if="p.spec">{{ p.spec }}</div>
      <div class="price-row">
        <span class="price">¥{{ p.price }}</span>
        <span class="mmk">≈K{{ (p.price * 250).toLocaleString() }}</span>
        <div class="add-btn" @click.stop="emit('add', p)">+</div>
      </div>
    </div>
  </div>
</template>

<script setup>
defineProps({ p: Object })
const emit = defineEmits(['add'])
</script>

<style scoped>
.product-card { display:flex; gap:10px; padding:12px 0; border-bottom:1px solid #f5f5f5; }
.img-wrap { position:relative; width:80px; height:80px; border-radius:8px; overflow:hidden; background:#fff5f0; flex-shrink:0; display:flex; align-items:center; justify-content:center; }
.emoji { font-size:36px; }
.img-wrap img { width:100%; height:100%; object-fit:cover; }
.label-tag { position:absolute; top:4px; left:4px; }
.detail { flex:1; display:flex; flex-direction:column; justify-content:space-between; }
.pname { font-size:14px; font-weight:600; color:#222; }
.spec { font-size:12px; color:#aaa; margin-top:2px; }
.price-row { display:flex; align-items:center; gap:6px; margin-top:auto; }
.price { font-size:16px; font-weight:700; color:#FF6B35; }
.mmk { font-size:11px; color:#aaa; }
.add-btn { margin-left:auto; width:28px; height:28px; border-radius:50%; background:#FF6B35; color:#fff; font-size:20px; line-height:28px; text-align:center; cursor:pointer; }
</style>