--1 

CREATE OR REPLACE FUNCTION calculer_points_semaine(ref_utilisateur_param IN INT)
RETURN INT
IS
  total_points INT := 0;
  points_taches_terminees INT := 0;
  ref_programme VARCHAR2(255);
BEGIN
  --  nom du programme de score utilisateur
  SELECT nom_programme INTO ref_programme
  FROM Utilisateur
  WHERE ref_utilisateur = ref_utilisateur_param;

  --  tâches terminées semaine
  SELECT COALESCE(SUM(CASE WHEN t.statut = 'Terminé' THEN s.score ELSE 0 END), 0)
  INTO points_taches_terminees
  FROM Tache_fini t
  JOIN Score_categorie_tache s ON t.nom_categorie = s.nom_categorie
  WHERE t.ref_utilisateur = ref_utilisateur_param
  AND t.date_realisation >= TRUNC(SYSDATE, 'IW') -- Début
  AND t.date_realisation < TRUNC(SYSDATE, 'IW') + 7; -- Fin de la semaine 

  -- les tâches non terminées
  SELECT COALESCE(SUM(CASE WHEN t.statut != 'Terminé' THEN -s.score ELSE 0 END), 0)
  INTO total_points
  FROM Tache_en_cours t
  JOIN Score_categorie_tache s ON t.nom_categorie = s.nom_categorie
  WHERE t.ref_utilisateur = ref_utilisateur_param
  AND (t.date_realisation IS NULL); 

  -- final
  total_points := points_taches_terminees - total_points;

  RETURN total_points;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0; 
END calculer_points_semaine;
/



--2

CREATE OR REPLACE PROCEDURE archiver_taches_passees AS
BEGIN
  -- tâches en cours expirées
  FOR task IN (SELECT * FROM Tache_en_cours WHERE date_d_echeance < SYSDATE) LOOP
    INSERT INTO Tache_fini (
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
      date_realisation) 
      
    VALUES (
      task.ref_tache,
      task.intitule,
      task.description,
      task.priorite,
      task.url,
      task.date_d_echeance,
      'Archivé', 
      task.nom_categorie,
      task.ref_periodicite,
      task.ref_utilisateur,
      task.date_realisation);

    -- Supprimer 
    DELETE FROM Tache_en_cours WHERE ref_tache = task.ref_tache;
  END LOOP;
  
  COMMIT; 
END archiver_taches_passees;
/



--3 , J'utilise Character Large Object pour les traitements 



-- Similarité
CREATE OR REPLACE FUNCTION calculer_similarite(str1 CLOB, str2 CLOB, mots_vides CLOB)
RETURN INT
IS
  nb_similarite INT := 0;
  sep VARCHAR2(10) := ' ';
  mots VARCHAR2(500);
BEGIN
  -- Lire 
  mots := DBMS_LOB.SUBSTR(str1, DBMS_LOB.GETLENGTH(str1), 1);

  FOR i IN 1..LENGTH(mots) LOOP
    IF INSTR(mots_vides, ' ' || SUBSTR(mots, i, 1) || ' ') = 0 THEN
      IF INSTR(str2, SUBSTR(mots, i, 1)) > 0 THEN
        nb_similarite := nb_similarite + 1;
      END IF;
    END IF;
  END LOOP;

  RETURN nb_similarite;
END calculer_similarite;
/




-- Taches similaires pour 1 utilisateur et 1 tache à comparer (seuil 50 mots)
CREATE OR REPLACE FUNCTION compter_taches_similaires(ref_utilisateur_param IN INT, ref_tache_param IN INT)
RETURN INT
IS
  nb_taches_similaires INT := 0;
  description_base CLOB;
  description_compare CLOB;
  seuil_similarite INT := 50; -- statique
  mots_vides CLOB := ' le la les un une des être avoir '; 
BEGIN
  
  SELECT description INTO description_base
  FROM tache_fini
  WHERE ref_tache = ref_tache_param;

  FOR autre_tache IN (SELECT * FROM tache_fini WHERE ref_utilisateur != ref_utilisateur_param) LOOP
    
    SELECT description INTO description_compare
    FROM tache_fini
    WHERE ref_tache = autre_tache.ref_tache;

    
    nb_taches_similaires := nb_taches_similaires + CASE
      WHEN calculer_similarite(description_base, description_compare, mots_vides) >= seuil_similarite
      THEN 1
      ELSE 0
    END;
  END LOOP;

  RETURN nb_taches_similaires;
END compter_taches_similaires;
/



-- Suggestions N = paramètre , Y = 5, utilisation d'un type pour stocker les occurences de chaque tâche

CREATE OR REPLACE PROCEDURE generer_suggestions(ref_utilisateur_param IN INT, nombre_suggestions IN INT)
IS
  TYPE suggestions_rec IS RECORD (
    ref_tache INT,
    nb_occurrences INT
  );

  TYPE suggestions_table IS TABLE OF suggestions_rec INDEX BY PLS_INTEGER;

  suggestions suggestions_table;
  nb_taches_similaires INT := 0;
  
BEGIN
  -- boucle utilisateurs
  FOR other_user IN (SELECT DISTINCT ref_utilisateur FROM Tache_en_cours WHERE ref_utilisateur != ref_utilisateur_param) LOOP
    
    nb_taches_similaires := 0;

    -- boucles taches à comparerer
    FOR task IN (SELECT * FROM tache_fini WHERE ref_utilisateur = ref_utilisateur_param) LOOP
      
      IF compter_taches_similaires(other_user.ref_utilisateur, task.ref_tache) > 0 THEN
    
        nb_taches_similaires := nb_taches_similaires + compter_taches_similaires(other_user.ref_utilisateur, task.ref_tache);
      END IF;
    END LOOP;

    -- utilisateur est similaire 
    IF nb_taches_similaires > 5 THEN
     
      FOR task IN (SELECT * FROM tache_fini WHERE ref_utilisateur = other_user.ref_utilisateur) LOOP
          
          IF suggestions.EXISTS(task.ref_tache) THEN
            suggestions(task.ref_tache).nb_occurrences := suggestions(task.ref_tache).nb_occurrences + 1;
          ELSE
            suggestions(task.ref_tache).ref_tache := task.ref_tache;
            suggestions(task.ref_tache).nb_occurrences := 1;
        END IF;
      END LOOP;
    END IF;
  END LOOP;

  -- Trier 
  FOR i IN 1..nombre_suggestions LOOP
    FOR j IN 1..nombre_suggestions - 1 LOOP
      IF suggestions(j).nb_occurrences < suggestions(j + 1).nb_occurrences THEN
        suggestions(j + 1) := suggestions(j);
      END IF;
    END LOOP;
  END LOOP;

  -- Afficher 
  FOR i IN 1..nombre_suggestions LOOP
    DBMS_OUTPUT.PUT_LINE('Suggestion ' || i || ': Tâche ' || suggestions(i).ref_tache || ' (Occurrences : ' || suggestions(i).nb_occurrences || ')');
  END LOOP;
END generer_suggestions;
/


















