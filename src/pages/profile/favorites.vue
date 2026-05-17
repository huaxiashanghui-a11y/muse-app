<template>
  <div class="page-no-tab">
    <van-nav-bar title="我的收藏" left-arrow @click-left="$router.back()" :border="false" />
    <van-tabs v-model:active="tab" color="#FF6B35" title-active-color="#FF6B35">
      <van-tab title="收藏商家" name="merchant">
        <div v-if="loading" class="loading-wrap"><van-loading color="#FF6B35" /></div>
        <van-empty v-else-if="merchants.length===0" description="暂无收藏商家" />
        <merchant-card v-else v-for="m in merchants" :key="m.id" :m="m" />
      </van-tab>
    </van-tabs>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { supabase } from '@/lib/supabase'
import { useAuthStore } from '@/stores/auth'
import MerchantCard from '@/components/home/MerchantCard.vue'

const auth = useAuthStore()
const tab = ref('merchant')
const loading = ref(true)
const merchants = ref([])

onMounted(async () => {
  if (!auth.isLoggedIn) { loading.value = false; return }
  const { data } = await supabase.from('favorites').select('merchant_id, merchants(*)').eq('user_id', auth.userId).eq('type', 'merchant')
  merchants.value = data?.map(f => f.merchants).filter(Boolean) || []
  loading.value = false
})
</script>
<style scoped>.loading-wrap{padding:60px;text-align:center}</style>