import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const routes = [
  { path: '/', redirect: '/home' },
  { path: '/home',     name: 'HomeIndex',     component: () => import('@/pages/home/index.vue') },
  { path: '/food',     name: 'FoodIndex',     component: () => import('@/pages/food/index.vue') },
  { path: '/activity', name: 'ActivityIndex', component: () => import('@/pages/activity/index.vue') },
  { path: '/shop',     name: 'ShopIndex',     component: () => import('@/pages/shop/index.vue') },
  { path: '/cart',     name: 'CartIndex',     component: () => import('@/pages/cart/index.vue') },
  { path: '/profile',  name: 'ProfileIndex',  component: () => import('@/pages/profile/index.vue') },
  { path: '/merchant/:id', name: 'MerchantDetail', component: () => import('@/pages/merchant/detail.vue') },
  { path: '/order/confirm', name: 'OrderConfirm', component: () => import('@/pages/order/confirm.vue'), meta: { auth: true } },
  { path: '/order/list',    name: 'OrderList',    component: () => import('@/pages/order/list.vue'),    meta: { auth: true } },
  { path: '/order/:id',     name: 'OrderDetail',  component: () => import('@/pages/order/detail.vue'),  meta: { auth: true } },
  { path: '/auth/login',    name: 'Login',    component: () => import('@/pages/auth/login.vue') },
  { path: '/auth/register', name: 'Register', component: () => import('@/pages/auth/register.vue') },
  { path: '/invite',    name: 'Invite',   component: () => import('@/pages/invite/index.vue'),   meta: { auth: true } },
  { path: '/member',    name: 'Member',   component: () => import('@/pages/member/index.vue'),   meta: { auth: true } },
  { path: '/points',    name: 'Points',   component: () => import('@/pages/points/index.vue'),   meta: { auth: true } },
  { path: '/address',   name: 'AddressList', component: () => import('@/pages/address/list.vue'), meta: { auth: true } },
  { path: '/address/edit', name: 'AddressEdit', component: () => import('@/pages/address/edit.vue'), meta: { auth: true } },
  { path: '/profile/favorites',    component: () => import('@/pages/profile/favorites.vue'),    meta: { auth: true } },
  { path: '/profile/help',         component: () => import('@/pages/profile/help.vue') },
  { path: '/profile/security',     component: () => import('@/pages/profile/security.vue'),     meta: { auth: true } },
  { path: '/profile/settings',     component: () => import('@/pages/profile/settings.vue'),     meta: { auth: true } },
  { path: '/merchant/apply',       component: () => import('@/pages/merchant/apply.vue') },
  { path: '/profile/rider-apply',  component: () => import('@/pages/profile/rider-apply.vue') },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior: () => ({ top: 0 }),
})

router.beforeEach(async (to) => {
  if (!to.meta.auth) return true
  const auth = useAuthStore()
  if (auth.loading) await new Promise(r => setTimeout(r, 300))
  if (!auth.isLoggedIn) return { path: '/auth/login', query: { redirect: to.fullPath } }
  return true
})

export default router