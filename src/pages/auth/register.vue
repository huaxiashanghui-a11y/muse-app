<template>
  <div class="auth-page">
    <div class="auth-logo">🍜</div>
    <div class="auth-title">注册 Muse</div>
    <div class="auth-sub">注册即获 50 积分</div>

    <van-form @submit="onRegister" class="auth-form">
      <van-cell-group inset>
        <van-field v-model="nickname" label="昵称" placeholder="请输入昵称" :rules="[{required:true}]" />
        <van-field v-model="email" label="邮箱" placeholder="请输入邮箱" type="email" :rules="[{required:true}]" />
        <van-field v-model="password" label="密码" placeholder="至少6位" type="password" :rules="[{required:true,min:6}]" />
        <van-field v-model="inviteCode" label="邀请码" placeholder="选填" />
      </van-cell-group>
      <div class="form-actions">
        <van-button block type="primary" native-type="submit" color="#FF6B35" round size="large" :loading="loading">注册</van-button>
        <van-button block plain color="#FF6B35" round size="large" @click="$router.back()">已有账号，去登录</van-button>
      </div>
    </van-form>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { showToast } from 'vant'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const auth = useAuthStore()
const nickname = ref('')
const email = ref('')
const password = ref('')
const inviteCode = ref('')
const loading = ref(false)

async function onRegister() {
  loading.value = true
  try {
    await auth.register(email.value, password.value, nickname.value)
    showToast({ message: '注册成功！获得50积分', type: 'success' })
    router.replace('/home')
  } catch (e) {
    showToast(e.message || '注册失败')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.auth-page { min-height:100vh; display:flex; flex-direction:column; align-items:center; padding:60px 0 40px; background:#fff; }
.auth-logo { font-size:72px; margin-bottom:16px; }
.auth-title { font-size:24px; font-weight:800; color:#222; }
.auth-sub { font-size:14px; color:#aaa; margin-top:4px; margin-bottom:40px; }
.auth-form { width:100%; }
.form-actions { padding:24px 16px; display:flex; flex-direction:column; gap:12px; }
</style>