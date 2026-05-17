<template>
  <div class="page-no-tab">
    <van-nav-bar title="账号安全" left-arrow @click-left="$router.back()" :border="false" />
    <van-cell-group inset class="mt-2">
      <van-cell title="修改密码" is-link @click="showChangePwd=true" />
      <van-cell title="邮箱绑定" :value="auth.user?.email" />
    </van-cell-group>

    <van-dialog v-model:show="showChangePwd" title="修改密码" show-cancel-button @confirm="changePwd">
      <div style="padding:16px">
        <van-field v-model="newPwd" type="password" label="新密码" placeholder="至少6位" />
      </div>
    </van-dialog>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { showToast } from 'vant'
import { supabase } from '@/lib/supabase'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
const showChangePwd = ref(false)
const newPwd = ref('')

async function changePwd() {
  if (newPwd.value.length < 6) { showToast('密码至少6位'); return }
  const { error } = await supabase.auth.updateUser({ password: newPwd.value })
  if (!error) showToast({ message: '密码修改成功', type: 'success' })
  else showToast('修改失败')
  newPwd.value = ''
}
</script>
<style scoped>.mt-2{margin-top:12px}</style>