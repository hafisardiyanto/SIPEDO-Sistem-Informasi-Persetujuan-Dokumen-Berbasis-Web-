<script setup>
import { RouterView } from 'vue-router'
</script>

<template>
  <RouterView />
</template>

<style>
/* Reset dasar untuk aplikasi */
body, html {
  margin: 0;
  padding: 0;
  width: 100%;
  height: 100%;
  font-family: 'Inter', system-ui, -apple-system, sans-serif;
  background-color: #f8fafc;
}

#app {
  width: 100%;
  height: 100vh;
}
</style>
