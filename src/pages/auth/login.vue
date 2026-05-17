<template>
  <div class="auth-page">
    <div class="auth-logo">🍜</div>
    <div class="auth-title">Muse 同城外卖</div>
    <div class="auth-sub">缅甸本土一站式生活服务</div>

    <van-form @submit="onLogin" class="auth-form">
      <van-cell-group inset>
        <van-field v-model="email" name="email" label="邮箱" placeholder="请输入邮箱" type="email" :rules="[{required:true}]" />
        <van-field v-model="password" name="password" label="密码" placeholder="请输入密码" type="password" :rules="[{required:true,min:6}]" />
      </van-cell-group>
      <div class="form-actions">
        <van-button block type="primary" native-type="submit" color="#FF6B35" round size="large" :loading="loading">登录</van-button>
        <van-button block plain color="#FF6B35" round size="large" @click="$router.push('/auth/register')" class="mt-2">注册新账号</van-button>
      </div>
    </van-form>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { showToast } from 'vant'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const route = useRoute()
const auth = useAuthStore()
const email = ref('')
const password = ref('')
const loading = ref(false)

async function onLogin() {
  loading.value = true
  try {
    await auth.loginWithEmail(email.value, password.value)
    showToast({ message: '登录成功', type: 'success' })
    router.replace(route.query.redirect || '/home')
  } catch (e) {
    showToast(e.message || '登录失败，请检查邮箱和密码')
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
.mt-2 { margin-top:0; }
</style>