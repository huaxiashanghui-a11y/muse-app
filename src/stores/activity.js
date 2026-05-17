import { defineStore } from 'pinia'

export const useActivityStore = defineStore('activity', {
  state: () => ({
    hasNew: JSON.parse(localStorage.getItem('muse_act_dot') || 'true'),
  }),
  actions: {
    markRead() {
      this.hasNew = false
      localStorage.setItem('muse_act_dot', 'false')
    },
    setNew() {
      this.hasNew = true
      localStorage.setItem('muse_act_dot', 'true')
    },
  },
})