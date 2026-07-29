<script setup>
import { ref } from 'vue'
import axios from 'axios'
import { useRouter } from 'vue-router'

const router = useRouter()
const form = ref({ email: '', password: '' })
const error = ref('')
const loading = ref(false)

const handleLogin = async () => {
  error.value = ''
  loading.value = true
  try {
    // 1. Get CSRF Cookie for Sanctum SPA Auth
    await axios.get('/sanctum/csrf-cookie')
    
    // 2. Perform Login Request
    const loginRes = await axios.post('/api/login', form.value)
    const user = loginRes.data.data
    const token = loginRes.data.access_token
    localStorage.setItem('user', JSON.stringify(user))
    localStorage.setItem('token', token)
    
    // Redirect based on role
    if(user.role === 'pemohon') {
      router.push('/pemohon/dashboard')
    } else if(user.role === 'penilai') {
      router.push('/penilai/dashboard')
    } else {
      router.push('/')
    }
  } catch (err) {
    error.value = err.response?.data?.message || 'Login failed. Please check your credentials.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="login-container">
    <div class="login-card">
      <div class="branding">
        <h1>SIPEDO</h1>
        <p>Sistem Informasi Persetujuan Dokumen</p>
      </div>
      
      <form @submit.prevent="handleLogin" class="login-form">
        <div v-if="error" class="error-alert">{{ error }}</div>
        
        <div class="form-group">
          <label>Email Address</label>
          <input type="email" v-model="form.email" required placeholder="pemohon@example.com" />
        </div>
        
        <div class="form-group">
          <label>Password</label>
          <input type="password" v-model="form.password" required placeholder="••••••••" />
        </div>
        
        <button type="submit" :disabled="loading" class="btn-primary">
          {{ loading ? 'Mengautentikasi...' : 'Masuk SIPEDO' }}
        </button>
      </form>
    </div>
  </div>
</template>


