-- ============================================
-- Аналитические запросы для дашборда доставки
-- Источник: датасет Food Delivery Time Prediction (Kaggle)
-- ============================================

-- 1. Общая статистика
-- Показывает базовые метрики: сколько всего заказов,
-- среднее, минимальное и максимальное время доставки
SELECT 
    COUNT(*) AS number_of_orders,
    ROUND(AVG(time_taken_min), 2) AS avg_time_taken,
    MIN(time_taken_min) AS min_time_taken,
    MAX(time_taken_min) AS max_time_taken
FROM orders;

-- 2. Время доставки по типам транспорта
-- Выявляет, какой транспорт быстрее всего доставляет заказы
SELECT 
    vehicle_type,
    COUNT(*) AS number_of_orders,
    ROUND(AVG(time_taken_min), 2) AS avg_time_taken,
    MIN(time_taken_min) AS min_time_taken,
    MAX(time_taken_min) AS max_time_taken
FROM orders
GROUP BY vehicle_type
ORDER BY avg_time_taken;

-- 3. Влияние погоды и трафика на время доставки
-- Показывает, как внешние факторы влияют на скорость
SELECT 
    weather,
    traffic_level,
    ROUND(AVG(time_taken_min), 2) AS avg_time_taken,
    COUNT(*) AS order_count
FROM orders
GROUP BY weather, traffic_level
ORDER BY weather, traffic_level;

-- 4. Топ-5 зон отправления по скорости доставки
-- Определяет зоны с самым быстрым временем доставки
SELECT 
    pickup_zone,
    ROUND(AVG(time_taken_min), 2) AS avg_time_taken,
    COUNT(*) AS order_count
FROM orders
GROUP BY pickup_zone
ORDER BY avg_time_taken
LIMIT 5;

-- 5. Зависимость времени от категории расстояния
-- Показывает, как расстояние влияет на время доставки
SELECT 
    delivery_distance_category,
    ROUND(AVG(road_distance_km), 2) AS avg_distance,
    ROUND(AVG(time_taken_min), 2) AS avg_duration,
    COUNT(*) AS number_of_orders
FROM orders
GROUP BY delivery_distance_category
ORDER BY avg_distance;

-- 6. Влияние загрузки ресторана на время приготовления и доставки
-- Выявляет, как загруженность ресторана влияет на общее время
SELECT 
    restaurant_load,
    ROUND(AVG(preparation_time_min), 2) AS avg_prep_time,
    ROUND(AVG(time_taken_min), 2) AS avg_time_taken,
    COUNT(*) AS number_of_orders
FROM orders
GROUP BY restaurant_load
ORDER BY 
    CASE restaurant_load
        WHEN 'Low' THEN 1
        WHEN 'Medium' THEN 2
        WHEN 'High' THEN 3
    END;

-- 7. Топ-5 популярных типов кухни
-- Показывает, какие кухни заказывают чаще всего
SELECT 
    cuisine_type,
    COUNT(*) AS orders_count,
    ROUND(AVG(time_taken_min), 2) AS avg_time
FROM orders
GROUP BY cuisine_type
ORDER BY orders_count DESC
LIMIT 5;

-- 8. Количество заказов и среднее время по дням недели
-- Выявляет пиковые дни и различия в скорости доставки
SELECT 
    day_of_week,
    COUNT(*) AS orders_count,
    ROUND(AVG(time_taken_min), 2) AS avg_time
FROM orders
GROUP BY day_of_week
ORDER BY 
    CASE day_of_week
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END;

-- 9. Влияние опыта курьера на время доставки
-- Показывает, быстрее ли доставляют опытные курьеры
WITH grouped AS (
    SELECT 
        CASE 
            WHEN rider_experience_years < 2 THEN 'менее 2 лет'
            WHEN rider_experience_years <= 5 THEN '2–5 лет'
            ELSE 'более 5 лет'
        END AS experience_group,
        time_taken_min
    FROM orders
)
SELECT 
    experience_group,
    ROUND(AVG(time_taken_min), 2) AS avg_time,
    COUNT(*) AS orders_count
FROM grouped
GROUP BY experience_group
ORDER BY 
    CASE experience_group
        WHEN 'менее 2 лет' THEN 1
        WHEN '2–5 лет' THEN 2
        ELSE 3
    END;

-- 10. Корреляция между временем приготовления и временем доставки
-- Показывает, насколько сильно время приготовления влияет на общее время
SELECT 
    CORR(preparation_time_min, time_taken_min) AS correlation
FROM orders;

-- 10b. Топ-5 заказов с самым долгим приготовлением
-- Используется для проверки выбросов и анализа аномалий
SELECT *
FROM orders
ORDER BY preparation_time_min DESC
LIMIT 5;