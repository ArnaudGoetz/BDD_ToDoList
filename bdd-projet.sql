--  Un utilisateur ne peut pas avoir le m�me login que d'autres utilisateurs.
--  Le format du login doit commencer par une lettre, suivi de 7 lettres minuscules, puis de 2 chiffres.
--  Le mot de passe doit contenir uniquement des lettres (majuscules/minuscules), des chiffres et le caract�re '_'.
--  Une t�che ne peut pas d�pendre d'elle-m�me.
--  Lorsqu'une t�che est marqu�e comme "Termin�e", un trigger doit �tre activ� pour la d�placer, cela se produit d�s qu'une t�che est termin�e ou qu'on atteint la date d'�ch�ance
--  Un trigger doit �tre activ� pour recalculer le score et le niveau de l'utilisateur � chaque ajout ou suppression d'une t�che.

-- Table pour stocker les informations sur les utilisateurs.
-- Elle est associ�e � d'autres tables pour g�rer les t�ches, les scores, etc.
CREATE TABLE Utilisateurs (
    utilisateur_id INT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50) NOT NULL,
    adresse VARCHAR(100),
    date_naissance DATE,
    date_inscription DATE,
    login VARCHAR(10) NOT NULL UNIQUE,
    mot_de_passe VARCHAR(100) NOT NULL,
    CONSTRAINT check_login_format CHECK (REGEXP_LIKE(login, '^[a-z]{1}[a-z]{7}[0-9]{2}$')),
    CONSTRAINT check_password_format CHECK (REGEXP_LIKE(mot_de_passe, '^[A-Za-z0-9_]+$'))
);

-- Table pour stocker les informations sur les t�ches.
-- Chaque t�che est associ�e � un utilisateur.
-- Elle peut �galement avoir des d�pendances avec d'autres t�ches et �tre li�e � des listes de t�ches.
-- Une t�che peut �tre p�riodique et r�f�rencer une t�che p�riodique sp�cifique.
CREATE TABLE Taches (
    tache_id INT PRIMARY KEY,
    utilisateur_id INT,
    intitule VARCHAR(100) NOT NULL,
    description TEXT,
    date_echeance DATE,
    priorite INT,
    statut BOOLEAN NOT NULL,
    lien_externe VARCHAR(255),
    tache_periodique_id INT,
    FOREIGN KEY (utilisateur_id) REFERENCES Utilisateurs(utilisateur_id),
    FOREIGN KEY (tache_periodique_id) REFERENCES TachesPeriodiques(tache_periodique_id)
);

-- Table pour g�rer les t�ches p�riodiques.
-- Chaque t�che p�riodique est li�e � une t�che sp�cifique.
-- Elle stocke des informations sur la r�currence des t�ches.
CREATE TABLE TachesPeriodiques (
    tache_periodique_id INT PRIMARY KEY,
    tache_id INT NOT NULL,
    date_debut DATE,
    date_fin DATE,
    frequence VARCHAR(20),
    FOREIGN KEY (tache_id) REFERENCES Taches(tache_id)
);

-- Table pour g�rer les d�pendances entre les t�ches.
-- Chaque entr�e relie une t�che � une t�che d�pendante.
-- Des contraintes sont en place pour �viter que les t�ches ne d�pendent d'elles-m�mes.
CREATE TABLE Dependances (
    tache_id INT NOT NULL,
    tache_dependante_id INT NOT NULL,
    FOREIGN KEY (tache_id) REFERENCES Taches(tache_id),
    FOREIGN KEY (tache_dependante_id) REFERENCES Taches(tache_id),
    CONSTRAINT check_dependance_different CHECK (tache_id <> tache_dependante_id)
);

-- Table pour stocker des listes de t�ches.
-- Chaque liste est associ�e � un utilisateur.
CREATE TABLE ListesDeTaches (
    liste_de_taches_id INT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    utilisateur_id INT,
    FOREIGN KEY (utilisateur_id) REFERENCES Utilisateurs(utilisateur_id)
);

-- Table de jonction pour associer des t�ches � des listes de t�ches sp�cifiques.
-- Elle relie des t�ches � des listes de t�ches.
CREATE TABLE TachesListesDeTaches (
    tache_id INT NOT NULL,
    liste_de_taches_id INT NOT NULL,
    FOREIGN KEY (tache_id) REFERENCES Taches(tache_id),
    FOREIGN KEY (liste_de_taches_id) REFERENCES ListesDeTaches(liste_de_taches_id),
    PRIMARY KEY (tache_id, liste_de_taches_id)
);

-- Table de jonction pour associer des utilisateurs � des t�ches.
-- Elle relie des utilisateurs � des t�ches.
CREATE TABLE UtilisateursTaches (
    tache_id INT NOT NULL,
    utilisateur_id INT NOT NULL,
    FOREIGN KEY (tache_id) REFERENCES Taches(tache_id),
    FOREIGN KEY (utilisateur_id) REFERENCES Utilisateurs(utilisateur_id),
    PRIMARY KEY (tache_id, utilisateur_id)
);

-- Table pour stocker les t�ches pass�es.
-- Chaque entr�e enregistre une t�che accomplie par son ID avec la date de r�alisation.
CREATE TABLE TachesPassees (
    tache_passee_id INT PRIMARY KEY,
    tache_id INT NOT NULL,
    date_realisation DATE,
    FOREIGN KEY (tache_id) REFERENCES Taches(tache_id)
);

-- Table pour stocker les scores des utilisateurs.
-- Chaque score est associ� � un utilisateur et comporte un niveau.
CREATE TABLE Scores (
    score_id INT PRIMARY KEY,
    utilisateur_id INT NOT NULL,
    score INT NOT NULL,
    niveau INT NOT NULL,
    FOREIGN KEY (utilisateur_id) REFERENCES Utilisateurs(utilisateur_id)
);

