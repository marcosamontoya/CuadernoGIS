-- ============================================
-- SCHEMA PARA CONTROL DE HORAS CON MAPAS GIS
-- Opción con cuarteles georreferenciados
-- ============================================

-- Extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- ============================================
-- TABLA: fincas
-- ============================================
CREATE TABLE fincas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(100) NOT NULL UNIQUE,
    ubicacion TEXT,
    activa BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_fincas_nombre ON fincas(nombre);
CREATE INDEX idx_fincas_activa ON fincas(activa);

-- ============================================
-- TABLA: cuarteles (CON GEOMETRÍA)
-- ============================================
CREATE TABLE cuarteles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    finca_id UUID NOT NULL REFERENCES fincas(id) ON DELETE CASCADE,
    nombre VARCHAR(100) NOT NULL,
    variedad VARCHAR(100), -- OPCIONAL
    
    -- Geometría del cuartel (polígono)
    geometry GEOMETRY(POLYGON, 4326),
    
    -- Superficie calculada automáticamente desde la geometría
    superficie_hectareas DECIMAL(10,2),
    
    -- Datos adicionales
    cultivo VARCHAR(100),
    rendimiento_estimado DECIMAL(10,2), -- kg/ha o ton/ha
    color_mapa VARCHAR(7) DEFAULT '#4a7c2a', -- Color hex para visualización
    
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(finca_id, nombre)
);

-- Índices espaciales
CREATE INDEX idx_cuarteles_geometry ON cuarteles USING GIST(geometry);
CREATE INDEX idx_cuarteles_finca_id ON cuarteles(finca_id);
CREATE INDEX idx_cuarteles_nombre ON cuarteles(nombre);
CREATE INDEX idx_cuarteles_variedad ON cuarteles(variedad);
CREATE INDEX idx_cuarteles_cultivo ON cuarteles(cultivo);
CREATE INDEX idx_cuarteles_activo ON cuarteles(activo);

-- ============================================
-- TABLA: trabajadores
-- ============================================
CREATE TABLE trabajadores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    rut VARCHAR(20) UNIQUE,
    telefono VARCHAR(20),
    email VARCHAR(100),
    fecha_ingreso DATE,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_trabajadores_nombre ON trabajadores(nombre);
CREATE INDEX idx_trabajadores_apellido ON trabajadores(apellido);
CREATE INDEX idx_trabajadores_rut ON trabajadores(rut);
CREATE INDEX idx_trabajadores_activo ON trabajadores(activo);

-- ============================================
-- TABLA: tipos_labor
-- ============================================
CREATE TABLE tipos_labor (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_tipos_labor_nombre ON tipos_labor(nombre);
CREATE INDEX idx_tipos_labor_activo ON tipos_labor(activo);

-- ============================================
-- TABLA: registros_horas
-- ============================================
CREATE TABLE registros_horas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    fecha DATE NOT NULL,
    trabajador_id UUID NOT NULL REFERENCES trabajadores(id) ON DELETE RESTRICT,
    cuartel_id UUID NOT NULL REFERENCES cuarteles(id) ON DELETE RESTRICT,
    tipo_labor_id UUID NOT NULL REFERENCES tipos_labor(id) ON DELETE RESTRICT,
    horas DECIMAL(5,2) NOT NULL CHECK (horas > 0 AND horas <= 24),
    
    -- Ubicación GPS donde se registró (opcional)
    ubicacion_registro GEOMETRY(POINT, 4326),
    
    observaciones TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_registros_fecha ON registros_horas(fecha);
CREATE INDEX idx_registros_trabajador_id ON registros_horas(trabajador_id);
CREATE INDEX idx_registros_cuartel_id ON registros_horas(cuartel_id);
CREATE INDEX idx_registros_tipo_labor_id ON registros_horas(tipo_labor_id);
CREATE INDEX idx_registros_fecha_trabajador ON registros_horas(fecha, trabajador_id);
CREATE INDEX idx_registros_ubicacion ON registros_horas USING GIST(ubicacion_registro);

-- ============================================
-- TRIGGERS PARA CALCULAR SUPERFICIE
-- ============================================
CREATE OR REPLACE FUNCTION calcular_superficie_cuartel()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.geometry IS NOT NULL THEN
        -- Calcular área en hectáreas
        NEW.superficie_hectareas = ROUND(
            (ST_Area(NEW.geometry::geography) / 10000)::NUMERIC, 
            2
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_calcular_superficie
    BEFORE INSERT OR UPDATE OF geometry ON cuarteles
    FOR EACH ROW
    EXECUTE FUNCTION calcular_superficie_cuartel();

-- ============================================
-- FUNCIONES DE TRIGGER PARA updated_at
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_fincas_updated_at BEFORE UPDATE ON fincas
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cuarteles_updated_at BEFORE UPDATE ON cuarteles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_trabajadores_updated_at BEFORE UPDATE ON trabajadores
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tipos_labor_updated_at BEFORE UPDATE ON tipos_labor
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_registros_horas_updated_at BEFORE UPDATE ON registros_horas
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- VISTA: registros_completos (CON DATOS GIS)
-- ============================================
CREATE OR REPLACE VIEW registros_completos AS
SELECT 
    rh.id,
    rh.fecha,
    rh.horas,
    rh.observaciones,
    ST_AsGeoJSON(rh.ubicacion_registro) AS ubicacion_json,
    t.id AS trabajador_id,
    t.nombre AS trabajador_nombre,
    t.apellido AS trabajador_apellido,
    t.rut AS trabajador_rut,
    c.id AS cuartel_id,
    c.nombre AS cuartel_nombre,
    c.variedad AS cuartel_variedad,
    c.superficie_hectareas AS cuartel_superficie,
    c.cultivo AS cuartel_cultivo,
    c.rendimiento_estimado AS cuartel_rendimiento,
    ST_AsGeoJSON(c.geometry) AS cuartel_geometry_json,
    f.id AS finca_id,
    f.nombre AS finca_nombre,
    f.ubicacion AS finca_ubicacion,
    tl.id AS tipo_labor_id,
    tl.nombre AS tipo_labor_nombre,
    tl.descripcion AS tipo_labor_descripcion,
    rh.created_at,
    rh.updated_at
FROM registros_horas rh
JOIN trabajadores t ON rh.trabajador_id = t.id
JOIN cuarteles c ON rh.cuartel_id = c.id
JOIN fincas f ON c.finca_id = f.id
JOIN tipos_labor tl ON rh.tipo_labor_id = tl.id;

-- ============================================
-- VISTA: cuarteles_geojson
-- Para facilitar la exportación a mapas
-- ============================================
CREATE OR REPLACE VIEW cuarteles_geojson AS
SELECT 
    c.id,
    c.nombre,
    c.finca_id,
    f.nombre AS finca_nombre,
    c.variedad,
    c.cultivo,
    c.superficie_hectareas,
    c.rendimiento_estimado,
    c.color_mapa,
    c.activo,
    ST_AsGeoJSON(c.geometry)::json AS geometry_json,
    json_build_object(
        'type', 'Feature',
        'properties', json_build_object(
            'id', c.id,
            'nombre', c.nombre,
            'finca', f.nombre,
            'variedad', c.variedad,
            'cultivo', c.cultivo,
            'superficie_ha', c.superficie_hectareas,
            'rendimiento', c.rendimiento_estimado,
            'color', c.color_mapa
        ),
        'geometry', ST_AsGeoJSON(c.geometry)::json
    ) AS feature_json
FROM cuarteles c
JOIN fincas f ON c.finca_id = f.id;

-- ============================================
-- FUNCIÓN: Obtener cuarteles en formato GeoJSON
-- ============================================
CREATE OR REPLACE FUNCTION obtener_cuarteles_geojson(
    p_finca_id UUID DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'type', 'FeatureCollection',
        'features', json_agg(feature_json)
    ) INTO result
    FROM cuarteles_geojson
    WHERE (p_finca_id IS NULL OR finca_id = p_finca_id)
    AND activo = true;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FUNCIÓN: Crear cuartel desde GeoJSON
-- ============================================
CREATE OR REPLACE FUNCTION crear_cuartel_desde_geojson(
    p_finca_id UUID,
    p_nombre VARCHAR,
    p_geojson JSON,
    p_cultivo VARCHAR DEFAULT NULL,
    p_variedad VARCHAR DEFAULT NULL,
    p_rendimiento DECIMAL DEFAULT NULL,
    p_color VARCHAR DEFAULT '#4a7c2a'
)
RETURNS UUID AS $$
DECLARE
    nuevo_id UUID;
    geometria GEOMETRY;
BEGIN
    -- Convertir GeoJSON a geometría PostGIS
    geometria := ST_SetSRID(ST_GeomFromGeoJSON(p_geojson::text), 4326);
    
    -- Validar que sea un polígono
    IF ST_GeometryType(geometria) NOT IN ('ST_Polygon', 'ST_MultiPolygon') THEN
        RAISE EXCEPTION 'La geometría debe ser un polígono';
    END IF;
    
    -- Insertar cuartel
    INSERT INTO cuarteles (
        finca_id, 
        nombre, 
        geometry, 
        cultivo, 
        variedad, 
        rendimiento_estimado,
        color_mapa
    )
    VALUES (
        p_finca_id, 
        p_nombre, 
        geometria, 
        p_cultivo, 
        p_variedad, 
        p_rendimiento,
        p_color
    )
    RETURNING id INTO nuevo_id;
    
    RETURN nuevo_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FUNCIÓN: Verificar si un punto está dentro de un cuartel
-- ============================================
CREATE OR REPLACE FUNCTION punto_en_cuartel(
    p_lat DECIMAL,
    p_lng DECIMAL
)
RETURNS TABLE (
    cuartel_id UUID,
    cuartel_nombre VARCHAR,
    finca_nombre VARCHAR,
    cultivo VARCHAR,
    variedad VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.nombre,
        f.nombre,
        c.cultivo,
        c.variedad
    FROM cuarteles c
    JOIN fincas f ON c.finca_id = f.id
    WHERE ST_Contains(
        c.geometry,
        ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)
    )
    AND c.activo = true;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FUNCIÓN: Obtener estadísticas por cultivo
-- ============================================
CREATE OR REPLACE FUNCTION estadisticas_por_cultivo()
RETURNS TABLE (
    cultivo VARCHAR,
    total_cuarteles BIGINT,
    superficie_total DECIMAL,
    rendimiento_promedio DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.cultivo,
        COUNT(*)::BIGINT,
        ROUND(SUM(c.superficie_hectareas)::NUMERIC, 2),
        ROUND(AVG(c.rendimiento_estimado)::NUMERIC, 2)
    FROM cuarteles c
    WHERE c.activo = true
    AND c.cultivo IS NOT NULL
    GROUP BY c.cultivo
    ORDER BY SUM(c.superficie_hectareas) DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FUNCIÓN: Obtener horas por finca (con geometría)
-- ============================================
CREATE OR REPLACE FUNCTION obtener_horas_por_finca(
    p_finca_id UUID DEFAULT NULL,
    p_fecha_inicio DATE DEFAULT NULL,
    p_fecha_fin DATE DEFAULT NULL
)
RETURNS TABLE (
    finca_nombre VARCHAR,
    cuartel_nombre VARCHAR,
    cuartel_id UUID,
    variedad VARCHAR,
    cultivo VARCHAR,
    superficie DECIMAL,
    total_horas DECIMAL,
    total_registros BIGINT,
    geometry_json JSON
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        f.nombre AS finca_nombre,
        c.nombre AS cuartel_nombre,
        c.id AS cuartel_id,
        c.variedad,
        c.cultivo,
        c.superficie_hectareas,
        SUM(rh.horas)::DECIMAL AS total_horas,
        COUNT(*)::BIGINT AS total_registros,
        ST_AsGeoJSON(c.geometry)::JSON AS geometry_json
    FROM registros_horas rh
    JOIN cuarteles c ON rh.cuartel_id = c.id
    JOIN fincas f ON c.finca_id = f.id
    WHERE (p_finca_id IS NULL OR f.id = p_finca_id)
        AND (p_fecha_inicio IS NULL OR rh.fecha >= p_fecha_inicio)
        AND (p_fecha_fin IS NULL OR rh.fecha <= p_fecha_fin)
    GROUP BY f.nombre, c.nombre, c.id, c.variedad, c.cultivo, c.superficie_hectareas, c.geometry
    ORDER BY f.nombre, c.nombre;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- COMENTARIOS EN LAS TABLAS
-- ============================================
COMMENT ON TABLE fincas IS 'Catálogo de fincas o predios agrícolas';
COMMENT ON TABLE cuarteles IS 'Cuarteles georreferenciados con polígonos. Variedad es opcional.';
COMMENT ON TABLE trabajadores IS 'Registro de trabajadores agrícolas';
COMMENT ON TABLE tipos_labor IS 'Catálogo de tipos de labores agrícolas';
COMMENT ON TABLE registros_horas IS 'Registro diario de horas trabajadas con ubicación GPS opcional';

COMMENT ON COLUMN cuarteles.geometry IS 'Polígono del cuartel en formato PostGIS (EPSG:4326)';
COMMENT ON COLUMN cuarteles.superficie_hectareas IS 'Calculada automáticamente desde la geometría';
COMMENT ON COLUMN cuarteles.variedad IS 'Variedad cultivada (OPCIONAL)';
COMMENT ON COLUMN cuarteles.rendimiento_estimado IS 'Rendimiento estimado en kg/ha o ton/ha';
COMMENT ON COLUMN cuarteles.color_mapa IS 'Color hexadecimal para visualización en mapa';
COMMENT ON COLUMN registros_horas.ubicacion_registro IS 'Punto GPS donde se registró la labor (opcional)';

-- ============================================
-- DATOS DE EJEMPLO CON GEOMETRÍAS
-- ============================================

/*
-- Ejemplo de inserción con polígono
INSERT INTO fincas (nombre, ubicacion) VALUES 
    ('Finca Demo', 'San Juan, Argentina');

-- Obtener el ID de la finca
DO $$
DECLARE
    finca_id UUID;
BEGIN
    SELECT id INTO finca_id FROM fincas WHERE nombre = 'Finca Demo';
    
    -- Insertar cuartel con geometría (polígono simple)
    INSERT INTO cuarteles (finca_id, nombre, variedad, cultivo, geometry, rendimiento_estimado)
    VALUES (
        finca_id,
        'Cuartel Norte',
        'Malbec',
        'Vid',
        ST_GeomFromText('POLYGON((-68.5265 -31.5375, -68.5260 -31.5375, -68.5260 -31.5370, -68.5265 -31.5370, -68.5265 -31.5375))', 4326),
        8500.00
    );
END $$;
*/
