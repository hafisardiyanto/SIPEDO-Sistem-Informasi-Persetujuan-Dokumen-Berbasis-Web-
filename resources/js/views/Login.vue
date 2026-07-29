<template>
  <div class="flex items-center justify-center min-h-screen bg-gray-100">
    <div class="px-8 py-6 mt-4 text-left bg-white shadow-lg rounded-xl">
      <h3 class="text-2xl font-bold text-center">Login SIPEDO</h3>
      <form @submit.prevent="login">
        <div class="mt-4">
          <div>
            <label class="block" for="email">Email</label>
            <input type="email" placeholder="Email" v-model="email"
              class="w-full px-4 py-2 mt-2 border rounded-md focus:outline-none focus:ring-1 focus:ring-blue-600">
          </div>
          <div class="mt-4">
            <label class="block">Password</label>
            <input type="password" placeholder="Password" v-model="password"
              class="w-full px-4 py-2 mt-2 border rounded-md focus:outline-none focus:ring-1 focus:ring-blue-600">
          </div>
          <div class="flex items-baseline justify-between">
            <button class="px-6 py-2 mt-4 text-white bg-blue-600 rounded-lg hover:bg-blue-900" type="submit" :disabled="loading">
              {{ loading ? 'Loading...' : 'Login' }}
            </button>
            <a href="#" class="text-sm text-blue-600 hover:underline">Register</a>
          </div>
          <p v-if="error" class="mt-4 text-sm text-red-500">{{ error }}</p>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import axios from 'axios';

const email = ref('');
const password = ref('');
const error = ref('');
const loading = ref(false);
const router = useRouter();

const login = async () => {
    loading.value = true;
    error.value = '';
    try {
        const response = await axios.post('/api/login', {
            email: email.value,
            password: password.value
        });
        localStorage.setItem('token', response.data.access_token);
        localStorage.setItem('role', response.data.data.role);
        
        axios.defaults.headers.common['Authorization'] = `Bearer ${response.data.access_token}`;
        
        if (response.data.data.role === 'pemohon') {
            router.push('/pemohon/dashboard');
        } else {
            router.push('/penilai/dashboard');
        }
    } catch (err) {
        error.value = 'Kredensial tidak valid.';
    } finally {
        loading.value = false;
    }
};
</script>
