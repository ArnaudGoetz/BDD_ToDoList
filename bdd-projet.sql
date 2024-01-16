--  Un utilisateur ne peut pas avoir le même login que d'autres utilisateurs.
--  Le format du login doit commencer par une lettre, suivi de 7 lettres minuscules, puis de 2 chiffres.
--  Le mot de passe doit contenir uniquement des lettres (majuscules/minuscules), des chiffres et le caractère '_'.
--  Une tâche ne peut pas dépendre d'elle-même.
--  Lorsqu'une tâche est marquée comme "Terminée", un trigger doit être activé pour la déplacer, cela se produit dès qu'une tâche est terminée ou qu'on atteint la date d'échéance
--  Un trigger doit être activé pour recalculer le score et le niveau de l'utilisateur à chaque ajout ou suppression d'une tâche.

-- Table pour stocker les informations sur les utilisateurs.
-- Elle est associée à d'autres tables pour gérer les tâches, les scores, etc.
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

-- Table pour stocker les informations sur les tâches.
-- Chaque tâche est associée à un utilisateur.
-- Elle peut également avoir des dépendances avec d'autres tâches et être liée à des listes de tâches.
-- Une tâche peut être périodique et référencer une tâche périodique spécifique.
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

-- Table pour gérer les tâches périodiques.
-- Chaque tâche périodique est liée à une tâche spécifique.
-- Elle stocke des informations sur la récurrence des tâches.
CREATE TABLE TachesPeriodiques (
    tache_periodique_id INT PRIMARY KEY,
    tache_id INT NOT NULL,
    date_debut DATE,
    date_fin DATE,
    frequence VARCHAR(20),
    FOREIGN KEY (tache_id) REFERENCES Taches(tache_id)
);

-- Table pour gérer les dépendances entre les tâches.
-- Chaque entrée relie une tâche à une tâche dépendante.
-- Des contraintes sont en place pour éviter que les tâches ne dépendent d'elles-mêmes.
CREATE TABLE Dependances (
    tache_id INT NOT NULL,
    tache_dependante_id INT NOT NULL,
    FOREIGN KEY (tache_id) REFERENCES Taches(tache_id),
    FOREIGN KEY (tache_dependante_id) REFERENCES Taches(tache_id),
    CONSTRAINT check_dependance_different CHECK (tache_id <> tache_dependante_id)
);

-- Table pour stocker des listes de tâches.
-- Chaque liste est associée à un utilisateur.
CREATE TABLE ListesDeTaches (
    liste_de_taches_id INT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    utilisateur_id INT,
    FOREIGN KEY (utilisateur_id) REFERENCES Utilisateurs(utilisateur_id)
);

-- Table de jonction pour associer des tâches à des listes de tâches spécifiques.
-- Elle relie des tâches à des listes de tâches.
CREATE TABLE TachesListesDeTaches (
    tache_id INT NOT NULL,
    liste_de_taches_id INT NOT NULL,
    FOREIGN KEY (tache_id) REFERENCES Taches(tache_id),
    FOREIGN KEY (liste_de_taches_id) REFERENCES ListesDeTaches(liste_de_taches_id),
    PRIMARY KEY (tache_id, liste_de_taches_id)
);

-- Table de jonction pour associer des utilisateurs à des tâches.
-- Elle relie des utilisateurs à des tâches.
CREATE TABLE UtilisateursTaches (
    tache_id INT NOT NULL,
    utilisateur_id INT NOT NULL,
    FOREIGN KEY (tache_id) REFERENCES Taches(tache_id),
    FOREIGN KEY (utilisateur_id) REFERENCES Utilisateurs(utilisateur_id),
    PRIMARY KEY (tache_id, utilisateur_id)
);

-- Table pour stocker les tâches passées.
-- Chaque entrée enregistre une tâche accomplie par son ID avec la date de réalisation.
CREATE TABLE TachesPassees (
    tache_passee_id INT PRIMARY KEY,
    tache_id INT NOT NULL,
    date_realisation DATE,
    FOREIGN KEY (tache_id) REFERENCES Taches(tache_id)
);

-- Table pour stocker les scores des utilisateurs.
-- Chaque score est associé à un utilisateur et comporte un niveau.
CREATE TABLE Scores (
    score_id INT PRIMARY KEY,
    utilisateur_id INT NOT NULL,
    score INT NOT NULL,
    niveau INT NOT NULL,
    FOREIGN KEY (utilisateur_id) REFERENCES Utilisateurs(utilisateur_id)
);

