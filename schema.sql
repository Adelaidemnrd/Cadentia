-- ============================================================
-- BASE DE DONNÉES : CADENTIA - MARQUE JEAN D'AIGLE
-- Description : Structure de la base pour le CRM, le Dashboard
--               commercial et le suivi de prospection.
-- ============================================================

-- Table des établissements (Prospects et Clients)
CREATE TABLE etablissements (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(255) NOT NULL,
    type VARCHAR(100), -- Parfumerie, Concept Store, Maison de tradition...
    adresse TEXT,
    code_postal VARCHAR(10),
    ville VARCHAR(100),
    departement VARCHAR(10),
    pays VARCHAR(100) DEFAULT 'France',
    siret VARCHAR(14),
    siren VARCHAR(9),
    code_naf VARCHAR(10),
    telephone VARCHAR(20),
    email_general VARCHAR(255),
    site_web VARCHAR(255),
    statut VARCHAR(50) DEFAULT 'Prospect', -- Prospect, En discussion, Client, Ancien client
    ranking INT DEFAULT 0, -- 0, 1, 2, 3
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_derniere_maj DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    actif BOOLEAN DEFAULT TRUE
);

-- Table des marques (Concurrents et Benchmark)
CREATE TABLE marques (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nom_marque VARCHAR(255) NOT NULL,
    type VARCHAR(50), -- Propre (Jean d'Aigle), Benchmark, Concurrent
    site_web VARCHAR(255)
);

-- Table de liaison : quelles marques sont vendues dans quel établissement
CREATE TABLE etablissements_marques (
    id_etablissement INT,
    id_marque INT,
    date_detection DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_etablissement, id_marque),
    FOREIGN KEY (id_etablissement) REFERENCES etablissements(id) ON DELETE CASCADE,
    FOREIGN KEY (id_marque) REFERENCES marques(id) ON DELETE CASCADE
);

-- Table des contacts (Personnes physiques)
CREATE TABLE contacts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_etablissement INT,
    nom VARCHAR(100),
    prenom VARCHAR(100),
    email VARCHAR(255),
    telephone VARCHAR(20),
    role VARCHAR(100), -- Gérant, Responsable achat...
    FOREIGN KEY (id_etablissement) REFERENCES etablissements(id) ON DELETE CASCADE
);

-- Table des interactions (Historique commercial)
CREATE TABLE interactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_etablissement INT,
    id_contact INT NULL,
    date_interaction DATETIME DEFAULT CURRENT_TIMESTAMP,
    type_interaction VARCHAR(50), -- Appel, Email, Visite, Envoi échantillons, Note
    duree INT, -- Durée en minutes
    resultat VARCHAR(50), -- Positif, Négatif, À relancer
    commentaire TEXT,
    date_prochaine_action DATETIME,
    id_odoo INT, -- Pour lier à l'activité dans Odoo
    FOREIGN KEY (id_etablissement) REFERENCES etablissements(id) ON DELETE CASCADE,
    FOREIGN KEY (id_contact) REFERENCES contacts(id) ON DELETE SET NULL
);

-- Table des gammes (Familles de produits Jean d'Aigle)
CREATE TABLE gammes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nom_gamme VARCHAR(100) NOT NULL, -- Eau de Cologne, Eau de Parfum, Parfum, Élixir
    description TEXT
);

-- Table des produits (Références Jean d'Aigle)
CREATE TABLE produits (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_gamme INT,
    nom_produit VARCHAR(255) NOT NULL,
    format VARCHAR(50), -- 30ml, 50ml, 100ml
    prix_public DECIMAL(10, 2), -- Prix public conseillé (PVC)
    prix_achat DECIMAL(10, 2), -- Prix de vente au revendeur
    cout_revient DECIMAL(10, 2), -- Coût de fabrication (confidentiel)
    actif BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_gamme) REFERENCES gammes(id)
);

-- Table de liaison : quel produit est vendu dans quel établissement
CREATE TABLE etablissements_produits (
    id_etablissement INT,
    id_produit INT,
    date_debut_vente DATETIME,
    date_fin_vente DATETIME NULL,
    PRIMARY KEY (id_etablissement, id_produit),
    FOREIGN KEY (id_etablissement) REFERENCES etablissements(id) ON DELETE CASCADE,
    FOREIGN KEY (id_produit) REFERENCES produits(id) ON DELETE CASCADE
);

-- Table des règles de marge (Paliers de remise)
CREATE TABLE regles_marge (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_produit INT,
    quantite_min INT,
    quantite_max INT,
    remise_pourcentage DECIMAL(5, 2),
    prix_achat_remise DECIMAL(10, 2),
    marge_revendeur_calculee DECIMAL(10, 2),
    actif BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_produit) REFERENCES produits(id) ON DELETE CASCADE
);

-- Table des barèmes de prix (Tarifs spécifiques par pays ou type de client)
CREATE TABLE baremes_prix (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_produit INT,
    type_client VARCHAR(100), -- Concept Store, Parfumerie, Distributeur
    pays VARCHAR(100),
    prix_achat_specifique DECIMAL(10, 2),
    date_debut_validite DATETIME,
    date_fin_validite DATETIME,
    FOREIGN KEY (id_produit) REFERENCES produits(id) ON DELETE CASCADE
);

-- Table des influenceurs
CREATE TABLE influenceurs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(255),
    langue VARCHAR(50),
    instagram VARCHAR(255),
    tiktok VARCHAR(255),
    followers_ig INT,
    followers_tt INT,
    email VARCHAR(255),
    statut VARCHAR(50), -- À contacter, Partenariat, Actif
    id_odoo INT
);

-- Table des objectifs commerciaux
CREATE TABLE objectifs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_commercial INT,
    periode VARCHAR(50), -- Mensuel, Trimestriel, Annuel
    date_debut DATETIME,
    date_fin DATETIME,
    objectif_ca DECIMAL(10, 2),
    objectif_nb_clients INT,
    objectif_nb_ventes INT,
    objectif_heures INT -- Pour le suivi des 80h / 5h
);

-- Table des taux de commission
CREATE TABLE taux_commission (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_gamme INT,
    type_commission VARCHAR(50), -- Pourcentage, Montant fixe, Palier
    valeur DECIMAL(10, 2),
    seuil_min DECIMAL(10, 2),
    seuil_max DECIMAL(10, 2),
    actif BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_gamme) REFERENCES gammes(id)
);

-- Table des simulations de vente
CREATE TABLE simulations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_commercial INT,
    nom_simulation VARCHAR(255),
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    id_etablissement INT NULL,
    id_produit INT,
    quantite INT,
    prix_unitaire DECIMAL(10, 2),
    ca_total DECIMAL(10, 2),
    commission_totale DECIMAL(10, 2),
    FOREIGN KEY (id_etablissement) REFERENCES etablissements(id) ON DELETE SET NULL,
    FOREIGN KEY (id_produit) REFERENCES produits(id)
);

-- Table des ventes réelles
CREATE TABLE ventes_reelles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_etablissement INT,
    id_produit INT,
    date_vente DAT'aETIME DEFAULT CURRENTure_TIMESTAMP,
    quantitez INT,
    mis prix_unitaire DECIMAL(10, 2),
    ca_total DECIMAL(10, 2),
    commission_calculee DECIMAL(10, 2),
    statut VARCHAR(50), -- En attente, Validée, Payée
    id_odoo INT,
    FOREIGN KEY (id_etablissement) REFERENCES etablissements(id),
    FOREIGN KEY (id_produit) REFERENCES produits(id)
);

-- Table du feedback terrain (Retours de la commerciale)
CREATE TABLE feedback_terrain (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_commercial INT,
    id_etablissement INT,
    date_feedback DATETIME DEFAULT CURRENT_TIMESTAMP,
    type_feedback VARCHAR(50), -- Produit, Prix, Packaging, Objection
    commentaire TEXT,
    priorite VARCHAR(50), -- Basse, Moyenne, Haute
    FOREIGN KEY (id_etablissement) REFERENCES etablissements(id) ON DELETE CASCADE
);

-- Table du suivi gifting (Échantillons envoyés)
CREATE TABLE suivi_gifting (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_etablissement INT,
    id_produit INT,
    date_envoi DATETIME,
    statut VARCHAR(50), -- Envoyé, Reçu, Relancé, Converti
    date_relance_prevue DATETIME,
    commentaire TEXT,
    FOREIGN KEY (id_etablissement) REFERENCES etablissements(id) ON DELETE CASCADE,
    FOREIGN KEY (id_produit) REFERENCES produits(id)
);

-- ============================================================
-- MODULE SCRAPING & ENRICHISSEMENT
-- ============================================================

-- Table des sources à scraper (Sites web des marques)
CREATE TABLE sources_scraping (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_marque INT, -- La marque concernée (ex: Diptyque)
    url_source VARCHAR(500), -- L'URL à scraper (ex: https://www.diptyqueparis.com/fr/fr/nos-boutiques)
    type_source VARCHAR(50), -- Site officiel, Annuaire, Google Maps, Réseau social
    frequence_scraping VARCHAR(50), -- Quotidien, Hebdomadaire, Mensuel
    derniere_execution DATETIME,
    statut VARCHAR(50) DEFAULT 'Actif', -- Actif, En pause, Erreur
    FOREIGN KEY (id_marque) REFERENCES marques(id) ON DELETE CASCADE
);

-- Table des résultats bruts du scraping (Avant validation)
CREATE TABLE resultats_scraping (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_source INT,
    date_scraping DATETIME DEFAULT CURRENT_TIMESTAMP,
    nom_detecte VARCHAR(255), -- Le nom du magasin détecté
    adresse_detectee TEXT,
    ville_detectee VARCHAR(100),
    code_postal_detecte VARCHAR(10),
    pays_detecte VARCHAR(100),
    telephone_detecte VARCHAR(20),
    site_web_detecte VARCHAR(255),
    marques_detectees TEXT, -- Liste des marques trouvées sur la page (format JSON)
    statut_validation VARCHAR(50) DEFAULT 'En attente', -- En attente, Validé, Rejeté, Doublon
    id_etablissement_cree INT NULL, -- Si validé, lien vers l'établissement créé
    FOREIGN KEY (id_source) REFERENCES sources_scraping(id) ON DELETE CASCADE,
    FOREIGN KEY (id_etablissement_cree) REFERENCES etablissements(id) ON DELETE SET NULL
);

-- Table des logs de scraping (Pour le suivi technique)
CREATE TABLE logs_scraping (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_source INT,
    date_execution DATETIME DEFAULT CURRENT_TIMESTAMP,
    statut VARCHAR(50), -- Succès, Échec, Partiel
    nb_resultats INT, -- Nombre de résultats trouvés
    message_erreur TEXT, -- Si échec, message d'erreur
    duree_execution INT, -- Durée en secondes
    FOREIGN KEY (id_source) REFERENCES sources_scraping(id) ON DELETE CASCADE
);

-- Table des mots-clés de matching (Pour le scoring automatique)
CREATE TABLE mots_cles_matching (
    id INT PRIMARY KEY AUTO_INCREMENT,
    mot_cle VARCHAR(255), -- Ex: "Diptyque", "Trudon", "Santa Maria Novella"
    id_marque INT NULL, -- Lien vers la marque si applicable
    type_mot_cle VARCHAR(50), -- Marque, Type de magasin, Produit
    poids INT DEFAULT 1, -- Poids pour le calcul du ranking
    actif BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_marque) REFERENCES marques(id) ON DELETE CASCADE
);

-- Table de l'historique des détections (Pour suivre l'évolution)
CREATE TABLE historique_detections (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_etablissement INT,
    id_marque INT,
    date_detection DATETIME DEFAULT CURRENT_TIMESTAMP,
    source_detection VARCHAR(50), -- Scraping, Manuel, API
    id_resultat_scraping INT NULL,
    FOREIGN KEY (id_etablissement) REFERENCES etablissements(id) ON DELETE CASCADE,
    FOREIGN KEY (id_marque) REFERENCES marques(id) ON DELETE CASCADE,
    FOREIGN KEY (id_resultat_scraping) REFERENCES resultats_scraping(id) ON DELETE SET NULL
);
