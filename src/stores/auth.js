import { defineStore } from 'pinia'
import { supabase } from '@/lib/supabase'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    profile: null,
    loading: true,
  }),
  getters: {
    isLoggedIn: (s) => !!s.user,
    userId: (s) => s.user?.id,
    nickname: (s) => s.profile?.nickname || s.user?.email?.split('@')[0] || '用户',
    avatar: (s) => s.profile?.avatar || '🧑',
    points: (s) => s.profile?.points || 0,
    commission: (s) => s.profile?.commission || 0,
    isMember: (s) => s.profile?.is_member || false,
    inviteCode: (s) => s.user ? 'MUSE' + s.user.id.replace(/-/g,'').slice(0,6).toUpperCase() : '',
  },
  actions: {
    async init() {
      this.loading = true
      const { data: { session } } = await supabase.auth.getSession()
      this.user = session?.user || null
      if (this.user) await this.fetchProfile()
      supabase.auth.onAuthStateChange(async (_e, session) => {
        this.user = session?.user || null
        if (this.user) await this.fetchProfile()
        else this.profile = null
      })
      this.loading = false
    },
    async fetchProfile() {
      if (!this.user) return
      const { data } = await supabase.from('profiles').select('*').eq('id', this.user.id).single()
      if (data) { this.profile = data; return }
      const np = { id: this.user.id, nickname: this.user.email?.split('@')[0], avatar: '🧑', points: 0, commission: 0, is_member: false }
      const { data: created } = await supabase.from('profiles').insert(np).select().single()
      this.profile = created
    },
    async loginWithEmail(email, password) {
      const { error } = await supabase.auth.signInWithPassword({ email, password })
      if (error) throw error
    },
    async register(email, password, nickname) {
      const { data, error } = await supabase.auth.signUp({ email, password })
      if (error) throw error
      if (data.user) {
        await supabase.from('profiles').upsert({ id: data.user.id, nickname, avatar: '🧑', points: 50 })
      }
    },
    async logout() {
      await supabase.auth.signOut()
      this.user = null
      this.profile = null
    },
    async updateProfile(updates) {
      if (!this.user) return
      const { data } = await supabase.from('profiles').update(updates).eq('id', this.user.id).select().single()
      if (data) this.profile = data
    },
    async addPoints(pts, type, desc) {
      if (!this.user) return
      await supabase.from('point_transactions').insert({ user_id: this.user.id, points: pts, type, description: desc })
      await supabase.from('profiles').update({ points: (this.profile?.points || 0) + pts }).eq('id', this.user.id)
      await this.fetchProfile()
    },
  },
})