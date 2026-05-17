<template>
  <div class="page-no-tab">
    <van-nav-bar title="收货地址" left-arrow @click-left="$router.back()" :border="false" right-text="新增" @click-right="$router.push('/address/edit')" />
    <div v-if="loading" class="loading-wrap"><van-loading color="#FF6B35" /></div>
    <van-empty v-else-if="addresses.length===0" description="暂无收货地址" />
    <van-swipe-cell v-else v-for="a in addresses" :key="a.id">
      <div :class="['addr-item', a.is_default&&'default']" @click="selectAddr(a)">
        <van-icon name="location-o" color="#FF6B35" size="20" class="addr-icon" />
        <div class="addr-info">
          <div class="addr-head"><span class="addr-name">{{ a.name }}</span><span class="addr-phone">{{ a.phone }}</span><van-tag v-if="a.is_default" type="danger" size="small">默认</van-tag></div>
          <div class="addr-detail">{{ a.detail }}</div>
        </div>
        <van-icon name="edit" color="#aaa" @click.stop="$router.push(`/address/edit?id=${a.id}`)" />
      </div>
      <template #right>
        <van-button square type="danger" text="删除" @click="deleteAddr(a.id)" style="height:100%" />
      </template>
    </van-swipe-cell>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { showToast } from 'vant'
import { supabase } from '@/lib/supabase'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
const route = useRoute()
const loading = ref(true)
const addresses = ref([])

async function fetchAddr() {
  if (!auth.isLoggedIn) { loading.value = false; return }
  const { data } = await supabase.from('addresses').select('*').eq('user_id', auth.userId).order('is_default', { ascending: false })
  addresses.value = data || []
  loading.value = false
}

function selectAddr(a) {
  if (route.query.pick) history.back()
}

async function deleteAddr(id) {
  await supabase.from('addresses').delete().eq('id', id)
  addresses.value = addresses.value.filter(a => a.id !== id)
  showToast('已删除')
}

onMounted(fetchAddr)
</script>

<style scoped>
.loading-wrap { padding:60px; text-align:center; }
.addr-item { display:flex; align-items:center; gap:12px; padding:16px; background:#fff; cursor:pointer; }
.addr-item.default { border-left:3px solid #FF6B35; }
.addr-info { flex:1; }
.addr-head { display:flex; align-items:center; gap:8px; margin-bottom:4px; }
.addr-name { font-size:15px; font-weight:600; }
.addr-phone { font-size:13px; color:#888; }
.addr-detail { font-size:13px; color:#666; }
</style>