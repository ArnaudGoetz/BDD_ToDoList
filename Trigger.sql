-- 1 
CREATE OR REPLACE TRIGGER score_update AFTER
    INSERT OR UPDATE ON tache_fini
    FOR EACH ROW
DECLARE
    points INT;
BEGIN
  --  points gagnés pour cette tâche ( selon la catégorie )
    SELECT
        coalesce(SUM(s.score),
                 0)
    INTO points
    FROM
        score_categorie_tache s
    WHERE
        s.nom_categorie = :new.nom_categorie;

    UPDATE utilisateur
    SET
        score = score + points
    WHERE
        ref_utilisateur = :new.ref_utilisateur;

END score_update;


-- 2 

CREATE OR REPLACE TRIGGER generer_taches_associees BEFORE
    INSERT OR UPDATE ON tache_en_cours
    FOR EACH ROW
DECLARE
    date_debut    TIMESTAMP;
    date_fin      TIMESTAMP;
    periode       INTERVAL DAY TO SECOND;
    nombre_taches NUMBER;
    v_ref_tache   INT;
BEGIN
    IF
        :new.date_d_echeance IS NOT NULL
        AND :new.ref_periodicite IS NOT NULL
    THEN
        SELECT
            date_debut,
            date_fin,
            periode
        INTO
            date_debut,
            date_fin,
            periode
        FROM
            periodicite
        WHERE
            ref_periodicite = :new.ref_periodicite;

        v_ref_tache := :new.ref_tache;
        nombre_taches := round((date_fin - date_debut) / periode) + 1;
        FOR i IN 1..nombre_taches LOOP
            INSERT INTO tache_en_cours (
                ref_tache,
                intitule,
                description,
                priorite,
                url,
                date_d_echeance,
                statut,
                nom_categorie,
                ref_periodicite,
                ref_utilisateur,
                date_realisation
            ) VALUES (
                v_ref_tache,
                :new.intitule,
                :new.description,
                :new.priorite,
                :new.url,
                date_debut + ( i - 1 ) * periode,
                'En cours',
                :new.nom_categorie,
                :new.ref_periodicite,
                :new.ref_utilisateur,
                NULL
            );

        END LOOP;
    END IF;
END generer_taches_associees;













