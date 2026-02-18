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
    url: 'https://mybgwrhllwwkghxcidgg.supabase.co',
    
    // Anon Key (llave pública)
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im15Ymd3cmhsbHd3a2doeGNpZGdnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA5NjkzNTQsImV4cCI6MjA4NjU0NTM1NH0.niko93scoz2CUOEPg2b2jCboGyTKJsNW8YsdiAyfs-c',
    
    // Opciones adicionales (opcional)
    options: {
        auth: {
            autoRefreshToken: true,
            persistSession: false,
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
