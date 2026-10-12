erDiagram
    etablissements {
        int id PK
        string nom
        string type
        string adresse
        string code_postal
        string ville
        string departement
        string pays
        string siret
        string siren
        string code_naf
        string telephone
        string email_general
        string site_web
        string statut
        int ranking
        decimal latitude
        decimal longitude
        datetime date_creation
        datetime date_derniere_maj
        boolean actif
    }

    marques {
        int id PK
        string nom_marque
        string type
        string site_web
    }

    etablissements_marques {
        int id_etablissement FK
        int id_marque FK
        datetime date_detection
    }

    contacts {
        int id PK
        int id_etablissement FK
        string nom
        string prenom
        string email
        string telephone
        string role
    }

    interactions {
        int id PK
        int id_etablissement FK
        int id_contact FK
        datetime date_interaction
        string type_interaction
        int duree
        string resultat
        text commentaire
        datetime date_prochaine_action
        int id_odoo
    }

    gammes {
        int id PK
        string nom_gamme
        string description
    }

    produits {
        int id PK
        int id_gamme FK
        string nom_produit
        string format
        decimal prix_public
        decimal prix_achat
        decimal cout_revient
        boolean actif
    }

    etablissements_produits {
        int id_etablissement FK
        int id_produit FK
        datetime date_debut_vente
        datetime date_fin_vente
    }

    regles_marge {
        int id PK
        int id_produit FK
        int quantite_min
        int quantite_max
        decimal remise_pourcentage
        decimal prix_achat_remise
        decimal marge_revendeur_calculee
        boolean actif
    }

    baremes_prix {
        int id PK
        int id_produit FK
        string type_client
        string pays
        decimal prix_achat_specifique
        datetime date_debut_validite
        datetime date_fin_validite
    }

    influenceurs {
        int id PK
        string nom
        string langue
        string instagram
        string tiktok
        int followers_ig
        int followers_tt
        string email
        string statut
        int id_odoo
    }

    objectifs {
        int id PK
        int id_commercial
        string periode
        datetime date_debut
        datetime date_fin
        decimal objectif_ca
        int objectif_nb_clients
        int objectif_nb_ventes
        int objectif_heures
    }

    taux_commission {
        int id PK
        int id_gamme FK
        string type_commission
        decimal valeur
        decimal seuil_min
        decimal seuil_max
        boolean actif
    }

    simulations {
        int id PK
        int id_commercial
        string nom_simulation
        datetime date_creation
        int id_etablissement FK
        int id_produit FK
        int quantite
        decimal prix_unitaire
        decimal ca_total
        decimal commission_totale
    }

    ventes_reelles {
        int id PK
        int id_etablissement FK
        int id_produit FK
        datetime date_vente
        int quantite
        decimal prix_unitaire
        decimal ca_total
        decimal commission_calculee
        string statut
        int id_odoo
    }

    feedback_terrain {
        int id PK
        int id_commercial
        int id_etablissement FK
        datetime date_feedback
        string type_feedback
        text commentaire
        string priorite
    }

    suivi_gifting {
        int id PK
        int id_etablissement FK
        int id_produit FK
        datetime date_envoi
        string statut
        datetime date_relance_prevue
        text commentaire
    }

    etablissements ||--o{ contacts : "a plusieurs"
    etablissements ||--o{ interactions : "a plusieurs"
    etablissements ||--o{ etablissements_marques : "vend"
    etablissements ||--o{ etablissements_produits : "vend"
    etablissements ||--o{ simulations : "concerne"
    etablissements ||--o{ ventes_reelles : "concerne"
    etablissements ||--o{ feedback_terrain : "concerne"
    etablissements ||--o{ suivi_gifting : "concerne"
    
    marques ||--o{ etablissements_marques : "est vendue dans"
    
    contacts ||--o{ interactions : "participe à"
    
    gammes ||--o{ produits : "contient"
    gammes ||--o{ taux_commission : "a des taux"
    
    produits ||--o{ etablissements_produits : "est vendu dans"
    produits ||--o{ regles_marge : "a des règles"
    produits ||--o{ baremes_prix : "a des tarifs"
    produits ||--o{ simulations : "concerne"
    produits ||--o{ ventes_reelles : "concerne"
    produits ||--o{ suivi_gifting : "concerne"