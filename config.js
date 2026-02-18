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
    url: 'https://vzeeimnbpxomjcmwxheu.supabase.co',
    
    // Anon Key (llave pública)
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ6ZWVpbW5icHhvbWpjbXd4aGV1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE0MjM2MzksImV4cCI6MjA4Njk5OTYzOX0.8LjPBwA28-FCAq5hpmRdddcOxRgfQ-IBZECrhgfstak',
    
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
