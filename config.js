// ============================================
// CONFIGURACIÓN DE SUPABASE
// ============================================

/**
 * Instrucciones para configurar:
 * 
 * 1. Ve a tu proyecto de Supabase (https://supabase.com)
 * 2. En Settings > API encontrarás:
 *    - Project URL
 *    - Project API keys > anon public
 * 3. Reemplaza los valores abajo con tus credenciales
 */

const SUPABASE_CONFIG = {
    // URL de tu proyecto Supabase
    url: 'https://hwlarsnbijjcvgrjmtkv.supabase.co',
    
    // Anon Key (llave pública)
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh3bGFyc25iaWpqY3ZncmptdGt2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE0MjAxMTgsImV4cCI6MjA4Njk5NjExOH0.uGI_EolxkOuhwhkjsAC_AuDs7mUWlvE1gGW-2wBHDjg',
    
    // Opciones adicionales (opcional)
    options: {
        auth: {
            autoRefreshToken: true,
            persistSession: true,
            detectSessionInUrl: true
        }
    }
};

// NO MODIFICAR ABAJO DE ESTA LÍNEA
// ============================================

// Exportar configuración
if (typeof module !== 'undefined' && module.exports) {
    module.exports = SUPABASE_CONFIG;
}
