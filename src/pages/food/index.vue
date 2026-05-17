<template>
  <tab-layout>
    <div class="page">
      <van-nav-bar title="外卖" :border="false" />
      <van-search v-model="keyword" placeholder="搜索商家" shape="round" @search="onSearch" class="pb-0" />
      <div class="sort-bar">
        <span v-for="s in sorts" :key="s.val" :class="['sort-item', sort===s.val&&'active']" @click="sort=s.val">{{ s.label }}</span>
      </div>
      <van-pull-refresh v-model="refreshing" @refresh="onRefresh">
        <div v-if="loading" class="loading-wrap"><van-loading color="#FF6B35" /></div>
        <template v-else>
          <merchant-card v-for="m in filtered" :key="m.id" :m="m" />
          <div class="list-end">已显示全部商家</div>
        </template>
      </van-pull-refresh>
    </div>
  </tab-layout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { supabase } from '@/lib/supabase'
import TabLayout from '@/components/layout/TabLayout.vue'
import MerchantCard from '@/components/home/MerchantCard.vue'

const keyword = ref('')
const sort = ref('default')
const refreshing = ref(false)
const loading = ref(true)
const merchants = ref([])

const sorts = [
  { val: 'default', label: '综合' },
  { val: 'distance', label: '距离' },
  { val: 'sales', label: '销量' },
]

const filtered = computed(() => {
  let list = merchants.value.filter(m => !keyword.value || m.name.includes(keyword.value))
  if (sort.value === 'sales') list = [...list].sort((a,b)=>b.monthly_sales-a.monthly_sales)
  return list
})

function onSearch() {}

async function fetchMerchants() {
  loading.value = true
  const { data } = await supabase.from('merchants').select('*').eq('is_active', true).order('sort_order')
  merchants.value = data || []
  loading.value = false
}

async function onRefresh() {
  await fetchMerchants()
  refreshing.value = false
}

onMounted(fetchMerchants)
</script>

<style scoped>
.sort-bar { display:flex; gap:0; padding:0 16px; border-bottom:1px solid #f0f0f0; background:#fff; }
.sort-item { padding:10px 16px; font-size:14px; color:#666; cursor:pointer; }
.sort-item.active { color:#FF6B35; font-weight:600; border-bottom:2px solid #FF6B35; }
.loading-wrap { padding:60px; text-align:center; }
.list-end { text-align:center; padding:20px; font-size:12px; color:#ccc; }
</style>