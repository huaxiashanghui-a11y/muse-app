import { defineStore } from 'pinia'

const KEY = 'muse_cart'

export const useCartStore = defineStore('cart', {
  state: () => ({
    items: JSON.parse(localStorage.getItem(KEY) || '[]'),
    merchantId: localStorage.getItem('muse_cart_mid') || null,
  }),
  getters: {
    count: (s) => s.items.reduce((a, i) => a + i.qty, 0),
    total: (s) => s.items.reduce((a, i) => a + i.price * i.qty, 0),
    isEmpty: (s) => s.items.length === 0,
  },
  actions: {
    addItem(item, mid) {
      if (this.merchantId && this.merchantId !== mid) {
        this.items = []
        this.merchantId = mid
      }
      if (!this.merchantId) this.merchantId = mid
      const ex = this.items.find((i) => i.id === item.id)
      if (ex) ex.qty++
      else this.items.push({ ...item, qty: 1 })
      this._save()
    },
    removeItem(id) {
      const ex = this.items.find((i) => i.id === id)
      if (ex) {
        ex.qty--
        if (ex.qty <= 0) this.items = this.items.filter((i) => i.id !== id)
      }
      this._save()
    },
    clear() {
      this.items = []
      this.merchantId = null
      localStorage.removeItem(KEY)
      localStorage.removeItem('muse_cart_mid')
    },
    _save() {
      localStorage.setItem(KEY, JSON.stringify(this.items))
      if (this.merchantId) localStorage.setItem('muse_cart_mid', this.merchantId)
    },
  },
})