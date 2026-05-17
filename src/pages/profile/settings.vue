<template>
  <div class="page-no-tab">
    <van-nav-bar title="个人设置" left-arrow @click-left="$router.back()" :border="false" />
    <van-form @submit="onSave" class="mt-2">
      <van-cell-group inset>
        <van-field v-model="form.nickname" label="昵称" placeholder="请输入昵称" />
        <van-field v-model="form.avatar" label="头像Emoji" placeholder="输入一个Emoji" />
        <van-field v-model="form.phone" label="手机号" placeholder="请输入手机号" type="tel" />
      </van-cell-group>
      <div style="padding:24px 16px">
        <van-button block color="#FF6B35" round size="large" native-type="submit" :loading="loading">保存</van-button>
      </div>
    </van-form>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { showToast } from 'vant'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
const loading = ref(false)
const form = ref({ nickname: auth.nickname, avatar: auth.avatar, phone: auth.profile?.phone || '' })

async function onSave() {
  loading.value = true
  await auth.updateProfile({ nickname: form.value.nickname, avatar: form.value.avatar, phone: form.value.phone })
  showToast({ message: '保存成功', type: 'success' })
  loading.value = false
}
</script>
<style scoped>.mt-2{margin-top:12px}</style>