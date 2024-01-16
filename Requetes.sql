
-- 1 

SELECT lt.ref_liste, COUNT(*) AS total_taches
FROM Liste_tache lt
JOIN Utilisateur u ON lt.ref_utilisateur = u.ref_utilisateur
WHERE u.pays = 'France'
GROUP BY lt.ref_liste
HAVING COUNT(*) >= 5;


-- 2
SELECT P.nom_programme, SUM(SCT.score) AS total_points
FROM Score_categorie_tache SCT
JOIN Tache_fini TF ON SCT.nom_categorie = TF.nom_categorie
JOIN Comporte P ON SCT.ref_score_categorie_tache = P.ref_score_categorie_tache
GROUP BY P.nom_programme
ORDER BY total_points DESC;


-- 3
SELECT U.login, U.nom, U.prenom, U.adresse, 
    COUNT(TEC.ref_tache) AS nombre_taches_total,
    COUNT(CASE WHEN P.ref_periodicite IS NOT NULL THEN 1 END) AS nombre_taches_periodiques
FROM Utilisateur U
JOIN Est_assigne EA ON U.ref_utilisateur = EA.ref_utilisateur
JOIN Tache_en_cours TEC ON EA.ref_tache = TEC.ref_tache
JOIN Periodicite P ON TEC.ref_periodicite = P.ref_periodicite
GROUP BY U.login, U.nom, U.prenom, U.adresse;


-- 4 
SELECT TE.ref_tache,COUNT(DISTINCT DD.ref_tache_1) AS nombre_dependances
FROM Tache_en_cours TE
LEFT JOIN Depend_de DD ON TE.ref_tache = DD.ref_tache_2
START WITH DD.ref_tache_1 IS NULL
CONNECT BY PRIOR DD.ref_tache_2 = DD.ref_tache_1
GROUP BY TE.ref_tache, TE.intitule
ORDER BY TE.ref_tache;

-- 5

WITH WeeklyScoreGain AS (
    SELECT
        EA.ref_utilisateur,
        SUM(SCT.score) AS weekly_score_gain
    FROM
        Est_assigne EA
    JOIN
        Tache_fini TF ON EA.ref_tache = TF.ref_tache
    JOIN
        Score_categorie_tache SCT ON TF.nom_categorie = SCT.nom_categorie
    WHERE
        TF.date_realisation >= TRUNC(SYSDATE, 'IW')  
        AND TF.date_realisation < TRUNC(SYSDATE, 'IW') + 7  
    GROUP BY
        EA.ref_utilisateur
)


SELECT
    U.login,
    U.nom,
    U.prenom,
    U.adresse,
    WS.weekly_score_gain,
    COUNT(TF.ref_tache) AS nombre_taches_finies
FROM
    Utilisateur U
JOIN
    WeeklyScoreGain WS ON U.ref_utilisateur = WS.ref_utilisateur
LEFT JOIN
    Est_assigne EA ON U.ref_utilisateur = EA.ref_utilisateur
LEFT JOIN
    Tache_fini TF ON EA.ref_tache = TF.ref_tache 
GROUP BY
    U.login, U.nom, U.prenom, U.adresse, WS.weekly_score_gain
ORDER BY
    WS.weekly_score_gain DESC
FETCH FIRST 10 ROWS ONLY;















































