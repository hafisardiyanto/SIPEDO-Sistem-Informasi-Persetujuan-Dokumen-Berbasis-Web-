<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const user = ref(JSON.parse(localStorage.getItem('user')))

const logout = () => {
    localStorage.removeItem('user')
    router.push('/')
}
</script>

<template>
  <div class="dashboard">
    <header class="header">
      <h2>Dashboard Penilai</h2>
      <div class="user-info">
        <span>Halo, {{ user?.name }}</span>
        <button @click="logout" class="btn-logout">Logout</button>
      </div>
    </header>
    
    <main class="content">
      <div class="card">
        <h3>Panel Penilai Dokumen</h3>
        <p>Anda login sebagai Penilai. Anda dapat me-review dokumen yang diajukan oleh pemohon dan memberikan status Setuju/Revisi/Tolak.</p>
      </div>
    </main>
  </div>
</template>

<style scoped>
.dashboard {
  font-family: 'Inter', sans-serif;
  background: #f1f5f9;
  min-height: 100vh;
}
.header {
  background: white;
  padding: 1rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}
.user-info {
  display: flex;
  align-items: center;
  gap: 1rem;
}
.btn-logout {
  background: #ef4444;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
}
.content {
  padding: 2rem;
}
.card {
  background: white;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 1px 2px rgba(0,0,0,0.05);
}
</style>
