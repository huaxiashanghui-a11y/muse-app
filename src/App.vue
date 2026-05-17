<template>
  <router-view v-slot="{ Component, route }">
    <keep-alive :include="['HomeIndex','FoodIndex','ActivityIndex','ShopIndex','ProfileIndex']">
      <component :is="Component" :key="route.path" />
    </keep-alive>
  </router-view>
</template>