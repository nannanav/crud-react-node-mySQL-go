import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';

// export default ({ mode }) => {
//   const env = loadEnv(mode, process.cwd());

//   return defineConfig({
//     plugins: [react()],
//     define: {
//       'import.meta.env.VITE_BACKEND_URL': JSON.stringify(process.env.VITE_BACKEND_URL),
//       'import.meta.env.VITE_BACKEND_URL': JSON.stringify(env.VITE_BACKEND_URL),
//       'import.meta.env.VITE_BACKEND_URL': JSON.stringify(
//         process.env.VITE_BACKEND_URL || env.VITE_BACKEND_URL
//       ),
//     },
//   });
// }

export default defineConfig({
  plugins: [react()],
})
