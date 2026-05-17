<template>
  <div class="page-no-tab">
    <van-nav-bar :title="isEdit?'编辑地址':'新增地址'" left-arrow @click-left="$router.back()" :border="false" />
    <van-form @submit="onSave" class="mt-2">
      <van-cell-group inset>
        <van-field v-model="form.name" label="姓名" placeholder="收货人姓名" :rules="[{required:true}]" />
        <van-field v-model="form.phone" label="手机号" placeholder="收货手机号" type="tel" :rules="[{required:true}]" />
        <van-field v-model="form.detail" label="详细地址" placeholder="街道、门牌号" type="textarea" rows="2" :rules="[{required:true}]" />
        <van-cell title="设为默认">
          <template #right-icon><van-switch v-model="form.is_default" size="20" active-color="#FF6B35" /></template>
        </van-cell>
      </van-cell-group>
      <div style="padding:24px 16px">
        <van-button block color="#FF6B35" round size="large" native-type="submit" :loading="loading">保存地址</van-button>
      </div>
    </van-form>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { showToast } from 'vant'
import { supabase } from '@/lib/supabase'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const route = useRoute()
const auth = useAuthStore()
const loading = ref(false)
const form = ref({ name:'', phone:'', detail:'', is_default:false })
const isEdit = computed(() => !!route.query.id)

onMounted(async () => {
  if (isEdit.value) {
    const { data } = await supabase.from('addresses').select('*').eq('id', route.query.id).single()
    if (data) form.value = { name:data.name, phone:data.phone, detail:data.detail, is_default:data.is_default }
  }
})

async function onSave() {
  if (!auth.isLoggedIn) { showToast('请先登录'); return }
  loading.value = true
  const payload = { ...form.value, user_id: auth.userId }
  if (isEdit.value) {
    await supabase.from('addresses').update(payload).eq('id', route.query.id)
  } else {
    await supabase.from('addresses').insert(payload)
  }
  showToast({ message: '保存成功', type: 'success' })
  router.back()
  loading.value = false
}
</script>
<style scoped>.mt-2{margin-top:12px}</style>