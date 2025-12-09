-- ================================
-- Lab 5 – Rapport mensuel d'emprunts
-- Fichier : lab5_exercice.sql
-- ================================

-- ================================
-- CTE 1 : Extraire les emprunts 2025 et calculer le mois et l'année
-- ================================
WITH emprunts_2025 AS (
    SELECT 
        YEAR(date_debut) AS annee,
        MONTH(date_debut) AS mois,
        id_abonne,
        id_ouvrage
    FROM emprunt
    WHERE YEAR(date_debut) = 2025
),

-- ================================
-- CTE 2 : Calcul des indicateurs de base par mois
-- ================================
indicateurs_mensuels AS (
    SELECT
        annee,
        mois,
        COUNT(*) AS total_emprunts,
        COUNT(DISTINCT id_abonne) AS abonnes_actifs,
        ROUND(COUNT(*) / COUNT(DISTINCT id_abonne), 2) AS moyenne_par_abonne
    FROM emprunts_2025
    GROUP BY annee, mois
),

-- ================================
-- CTE 3 : Comptage des emprunts par ouvrage et par mois
-- ================================
emprunts_par_ouvrage AS (
    SELECT
        annee,
        mois,
        id_ouvrage,
        COUNT(*) AS nb_emprunts
    FROM emprunts_2025
    GROUP BY annee, mois, id_ouvrage
),

-- ================================
-- CTE 4 : Top 3 ouvrages par mois avec ROW_NUMBER
-- ================================
top_3_ouvrages AS (
    SELECT
        e.annee,
        e.mois,
        o.titre,
        e.nb_emprunts,
        ROW_NUMBER() OVER (PARTITION BY e.annee, e.mois ORDER BY e.nb_emprunts DESC) AS rang
    FROM emprunts_par_ouvrage e
    JOIN ouvrage o ON o.id_ouvrage = e.id_ouvrage
)
-- ================================
-- Requête finale : assembler le rapport
-- ================================
SELECT 
    i.annee,
    i.mois,
    COALESCE(i.total_emprunts, 0) AS total_emprunts,
    COALESCE(i.abonnes_actifs, 0) AS abonnes_actifs,
    COALESCE(i.moyenne_par_abonne, 0) AS moyenne_par_abonne,
    COALESCE(ROUND(
        (SELECT COUNT(DISTINCT id_ouvrage) 
         FROM emprunts_2025 e2 
         WHERE e2.annee = i.annee AND e2.mois = i.mois) * 100.0
        / (SELECT COUNT(*) FROM ouvrage), 2
    ), 0) AS pct_ouvrages_empruntes,
    -- Concaténation des 3 ouvrages les plus empruntés
    COALESCE((
        SELECT GROUP_CONCAT(t.titre ORDER BY t.nb_emprunts DESC SEPARATOR ', ')
        FROM top_3_ouvrages t
        WHERE t.annee = i.annee AND t.mois = i.mois AND t.rang <= 3
    ), 'Aucun') AS top_3_ouvrages
FROM indicateurs_mensuels i
ORDER BY i.annee, i.mois;
