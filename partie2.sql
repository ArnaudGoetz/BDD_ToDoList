ALTER TABLE Comporte DROP CONSTRAINT FK_COMPORTE_REFSCORE_CATEGORIE;
ALTER TABLE Contient DROP CONSTRAINT FK_CONTIENT_REFLISTE;
ALTER TABLE Depend_de DROP CONSTRAINT FK_DEPEND_RETACHE1;
ALTER TABLE Depend_de DROP CONSTRAINT FK_DEPEND_RETACHE2;
ALTER TABLE Est_assigne DROP CONSTRAINT FK_EST_ASSIGNE_REFTACHE;
ALTER TABLE Est_assigne DROP CONSTRAINT FK_EST_ASSIGNE_REFUTILISATEUR;
ALTER TABLE Liste_tache DROP CONSTRAINT FK_LISTETACHE_REFUTILISATEUR;

ALTER TABLE Tache_fini DROP CONSTRAINT FK_TACHE_FINI_REF ;
ALTER TABLE Tache_fini DROP CONSTRAINT FK_TACHE_FINI_REF_REFUTILISATEUR ;
ALTER TABLE Tache_fini DROP CONSTRAINT FK_TACHE_FINI_REFPERIODICITE ;
ALTER TABLE Tache_en_cours DROP CONSTRAINT FK_TACHE_EN_COURS_REF ;
ALTER TABLE Tache_en_cours DROP CONSTRAINT FK_TACHE_EN_COURS_REFUTILISATEUR ;
ALTER TABLE Tache_en_cours DROP CONSTRAINT FK_TACHE_EN_COURS_REFPERIODICITE ;

ALTER TABLE Tache_appartenant_a_liste DROP CONSTRAINT FK_TACHELISTE_REFTACHE;
ALTER TABLE Tache_appartenant_a_liste DROP CONSTRAINT FK_TACHELISTE_REFLISTE;
ALTER TABLE Travaille DROP CONSTRAINT FK_TRAVAILLE_REFUTILISATEUR;


DROP TABLE Comporte;
DROP TABLE Contient;
DROP TABLE Depend_de;
DROP TABLE Est_assigne;
DROP TABLE Liste_tache;
DROP TABLE Periodicite;
DROP TABLE Score_categorie_tache;
DROP TABLE Tache;
DROP TABLE Tache_appartenant_a_liste;
DROP TABLE Travaille;
DROP TABLE Utilisateur;
DROP TABLE Tache_fini;
DROP TABLE Tache_en_cours;



CREATE TABLE Comporte (
  PRIMARY KEY (nom_programme, ref_score_categorie_tache),
  nom_programme             VARCHAR(255) NOT NULL,
  ref_score_categorie_tache VARCHAR(255) NOT NULL
);

CREATE TABLE Contient (
  PRIMARY KEY (nom_projet, ref_liste),
  nom_projet VARCHAR(255) NOT NULL,
  ref_liste  INT NOT NULL
);

CREATE TABLE Depend_de (
  PRIMARY KEY (ref_tache_1, ref_tache_2),
  ref_tache_1 INT NOT NULL,
  ref_tache_2 INT NOT NULL
);

CREATE TABLE Est_assigne (
  PRIMARY KEY (ref_utilisateur, ref_tache),
  ref_utilisateur INT NOT NULL,
  ref_tache       INT NOT NULL
);

CREATE TABLE Liste_tache (
  PRIMARY KEY (ref_liste),
  ref_liste       INT NOT NULL,
  nom_categorie   VARCHAR(255) NOT NULL,
  ref_utilisateur INT NOT NULL
);

CREATE TABLE Periodicite (
  PRIMARY KEY (ref_periodicite),
  ref_periodicite INT,
  date_debut TIMESTAMP NOT NULL,
  date_fin   TIMESTAMP,
  periode    INTERVAL DAY TO SECOND
);

CREATE TABLE Score_categorie_tache (
  PRIMARY KEY (ref_score_categorie_tache),
  ref_score_categorie_tache VARCHAR(255) NOT NULL,
  termine                   VARCHAR(1),
  score                     INT,
  nom_categorie             VARCHAR(255) NOT NULL
);

CREATE TABLE Tache (
  PRIMARY KEY (ref_tache),
  ref_tache        INT NOT NULL
);

CREATE TABLE Tache_en_cours (
  PRIMARY KEY (ref_tache),
  ref_tache        INT NOT NULL,
  intitule         VARCHAR(255),
  description      VARCHAR(4000),
  priorite         SMALLINT,
  url              VARCHAR(2000),
  date_d_echeance  TIMESTAMP,
  statut           VARCHAR(8),
  nom_categorie    VARCHAR(255) NOT NULL,
  ref_periodicite  INTEGER NOT NULL,
  ref_utilisateur  INT NOT NULL,
  date_realisation TIMESTAMP NULL
);

CREATE TABLE Tache_fini (
  PRIMARY KEY (ref_tache),
  ref_tache        INT NOT NULL,
  intitule         VARCHAR(255),
  description      VARCHAR(4000),
  priorite         SMALLINT,
  url              VARCHAR(2000),
  date_d_echeance  TIMESTAMP,
  statut           VARCHAR(8),
  nom_categorie    VARCHAR(255) NOT NULL,
  ref_periodicite  INTEGER NOT NULL,
  ref_utilisateur  INT NOT NULL,
  date_realisation TIMESTAMP NULL
);

CREATE TABLE Tache_appartenant_a_liste (
  PRIMARY KEY (ref_liste, ref_tache),
  ref_liste INT NOT NULL,
  ref_tache INT NOT NULL
);

CREATE TABLE Travaille (
  PRIMARY KEY (nom_projet, ref_utilisateur),
  nom_projet      VARCHAR(255) NOT NULL,
  ref_utilisateur INT NOT NULL
);

CREATE TABLE Utilisateur (
  PRIMARY KEY (ref_utilisateur),
  ref_utilisateur    INT NOT NULL,
  login              VARCHAR(10),
  mot_de_passe       VARCHAR(255),
  score              INT,
  nom                VARCHAR(255),
  prenom             VARCHAR(255),
  adresse            VARCHAR(511),
  pays               VARCHAR(100),
  date_de_naissance  DATE,
  date_d_inscription DATE,
  nom_programme      VARCHAR(255) NULL,
  UNIQUE (login)
);



ALTER TABLE Comporte ADD CONSTRAINT FK_COMPORTE_REFSCORE_CATEGORIE FOREIGN KEY (ref_score_categorie_tache) REFERENCES Score_categorie_tache (ref_score_categorie_tache);

ALTER TABLE Contient ADD CONSTRAINT FK_CONTIENT_REFLISTE FOREIGN KEY (ref_liste) REFERENCES Liste_tache (ref_liste);

ALTER TABLE Depend_de ADD CONSTRAINT FK_DEPEND_RETACHE1 FOREIGN KEY (ref_tache_2) REFERENCES Tache (ref_tache);
ALTER TABLE Depend_de ADD CONSTRAINT FK_DEPEND_RETACHE2 FOREIGN KEY (ref_tache_1) REFERENCES Tache (ref_tache);

ALTER TABLE Est_assigne ADD CONSTRAINT FK_EST_ASSIGNE_REFTACHE FOREIGN KEY (ref_tache) REFERENCES Tache (ref_tache);
ALTER TABLE Est_assigne ADD CONSTRAINT FK_EST_ASSIGNE_REFUTILISATEUR FOREIGN KEY (ref_utilisateur) REFERENCES Utilisateur (ref_utilisateur);

ALTER TABLE Liste_tache ADD CONSTRAINT FK_LISTETACHE_REFUTILISATEUR FOREIGN KEY (ref_utilisateur) REFERENCES Utilisateur (ref_utilisateur);

ALTER TABLE Tache_fini ADD CONSTRAINT FK_TACHE_FINI_REF FOREIGN KEY (ref_tache) REFERENCES Tache (ref_tache);
ALTER TABLE Tache_fini ADD CONSTRAINT FK_TACHE_FINI_REF_REFUTILISATEUR FOREIGN KEY (ref_utilisateur) REFERENCES Utilisateur (ref_utilisateur);
ALTER TABLE Tache_fini ADD CONSTRAINT FK_TACHE_FINI_REFPERIODICITE FOREIGN KEY (ref_periodicite) REFERENCES Periodicite (ref_periodicite);
ALTER TABLE Tache_en_cours ADD CONSTRAINT FK_TACHE_EN_COURS_REF FOREIGN KEY (ref_tache) REFERENCES Tache (ref_tache);
ALTER TABLE Tache_en_cours ADD CONSTRAINT FK_TACHE_EN_COURS_REFUTILISATEUR FOREIGN KEY (ref_utilisateur) REFERENCES Utilisateur (ref_utilisateur);
ALTER TABLE Tache_en_cours ADD CONSTRAINT FK_TACHE_EN_COURS_REFPERIODICITE FOREIGN KEY (ref_periodicite) REFERENCES Periodicite (ref_periodicite);
ALTER TABLE Tache_appartenant_a_liste ADD CONSTRAINT FK_TACHELISTE_REFTACHE FOREIGN KEY (ref_tache) REFERENCES Tache (ref_tache);
ALTER TABLE Tache_appartenant_a_liste ADD CONSTRAINT FK_TACHELISTE_REFLISTE FOREIGN KEY (ref_liste) REFERENCES Liste_tache (ref_liste);

ALTER TABLE Travaille ADD CONSTRAINT FK_TRAVAILLE_REFUTILISATEUR FOREIGN KEY (ref_utilisateur) REFERENCES Utilisateur (ref_utilisateur);

