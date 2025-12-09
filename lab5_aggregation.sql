-- ============================
-- Lab 5 – Agrégation MySQL
-- Fichier : lab5_aggregation.sql
-- ============================

-- ============================
-- Étape 1 – Connexion et sélection de la base
-- ============================
-- Dans le terminal système :
-- mysql -u root -p
-- USE bibliotheque;

-- ============================
-- Étape 2 – Fonctions d’agrégation
-- ============================

-- Nombre total d'abonnés
-- Permet de connaître la taille de la base abonnés
SELECT COUNT(*) AS total_abonnes
FROM abonne;

-- Moyenne d'emprunts par abonné
-- Utile pour comparer chaque abonné à la moyenne générale
SELECT AVG(nb) AS moyenne_emprunts
FROM (
    SELECT COUNT(*) AS nb
    FROM emprunt
    GROUP BY id_abonne
) AS sous;

-- Prix moyen des ouvrages (si la colonne prix_unitaire existe)
-- SELECT AVG(prix_unitaire) AS prix_moyen
-- FROM ouvrage;

-- ============================
-- Étape 3 – Utilisation de GROUP BY
-- ============================

-- Nombre d'emprunts par abonné
SELECT id_abonne, COUNT(*) AS nbre
FROM emprunt
GROUP BY id_abonne;

-- Nombre d'ouvrages par auteur
SELECT id_auteur, COUNT(*) AS total_ouvrages
FROM ouvrage
GROUP BY id_auteur;

-- ============================
-- Étape 4 – Filtrer avec HAVING
-- ============================

-- Abonnés avec au moins 3 emprunts
SELECT id_abonne, COUNT(*) AS nbre
FROM emprunt
GROUP BY id_abonne
HAVING COUNT(*) >= 3;

-- Auteurs avec plus de 5 ouvrages
SELECT id_auteur, COUNT(*) AS total_ouvrages
FROM ouvrage
GROUP BY id_auteur
HAVING total_ouvrages > 5;

-- ============================
-- Étape 5 – Jointures + agrégats
-- ============================

-- Nombre d'emprunts par abonné avec nom
SELECT a.nom, COUNT(e.id_emprunt) AS emprunts
FROM abonne a
LEFT JOIN emprunt e ON e.id_abonne = a.id
GROUP BY a.id, a.nom;

-- Nombre total d'emprunts pour chaque auteur
SELECT au.nom, COUNT(e.id_emprunt) AS total_emprunts
FROM auteur au
JOIN ouvrage o ON o.id_auteur = au.id
LEFT JOIN emprunt e ON e.id_ouvrage = o.id_ouvrage
GROUP BY au.id, au.nom;

-- ============================
-- Étape 6 – Analyses plus complexes
-- ============================

-- Pourcentage d'ouvrages empruntés
SELECT ROUND(
    COUNT(CASE WHEN e.id_emprunt IS NOT NULL THEN 1 END) * 100
    / COUNT(DISTINCT o.id_ouvrage), 2
) AS pct_empruntes
FROM ouvrage o
LEFT JOIN emprunt e ON e.id_ouvrage = o.id_ouvrage;

-- 3 abonnés les plus actifs
SELECT a.nom, COUNT(*) AS nbre_emprunts
FROM abonne a
JOIN emprunt e ON e.id_abonne = a.id
GROUP BY a.id, a.nom
ORDER BY nbre_emprunts DESC
LIMIT 3;

-- ============================
-- Étape 7 – CTE pour agrégation
-- ============================

WITH stats AS (
    SELECT o.id_auteur, COUNT(e.id_emprunt) AS emprunts, COUNT(DISTINCT o.id_ouvrage) AS ouvrages
    FROM ouvrage
