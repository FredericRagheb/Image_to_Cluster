------------------------------------------------------------------------------------------------------
ATELIER FROM IMAGE TO CLUSTER
------------------------------------------------------------------------------------------------------
L’idée en 30 secondes : Cet atelier consiste à **industrialiser le cycle de vie d’une application** simple en construisant une **image applicative Nginx** personnalisée avec **Packer**, puis en déployant automatiquement cette application sur un **cluster Kubernetes** léger (K3d) à l’aide d’**Ansible**, le tout dans un environnement reproductible via **GitHub Codespaces**.
L’objectif est de comprendre comment des outils d’Infrastructure as Code permettent de passer d’un artefact applicatif maîtrisé à un déploiement cohérent et automatisé sur une plateforme d’exécution.
  
-------------------------------------------------------------------------------------------------------
Séquence 1 : Codespace de Github
-------------------------------------------------------------------------------------------------------
Objectif : Création d'un Codespace Github  
Difficulté : Très facile (~5 minutes)
-------------------------------------------------------------------------------------------------------
**Faites un Fork de ce projet**. Si besion, voici une vidéo d'accompagnement pour vous aider dans les "Forks" : [Forker ce projet](https://youtu.be/p33-7XQ29zQ) 
  
Ensuite depuis l'onglet [CODE] de votre nouveau Repository, **ouvrez un Codespace Github**.
  
---------------------------------------------------
Séquence 2 : Création du cluster Kubernetes K3d
---------------------------------------------------
Objectif : Créer votre cluster Kubernetes K3d  
Difficulté : Simple (~5 minutes)
---------------------------------------------------
Vous allez dans cette séquence mettre en place un cluster Kubernetes K3d contenant un master et 2 workers.  
Dans le terminal du Codespace copier/coller les codes ci-dessous etape par étape :  

**Création du cluster K3d**  
```
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```
```
k3d cluster create lab \
  --servers 1 \
  --agents 2
```
**vérification du cluster**  
```
kubectl get nodes
```
**Déploiement d'une application (Docker Mario)**  
```
kubectl create deployment mario --image=sevenajay/mario
kubectl expose deployment mario --type=NodePort --port=80
kubectl get svc
```
**Forward du port 80**  
```
kubectl port-forward svc/mario 8080:80 >/tmp/mario.log 2>&1 &
```
**Réccupération de l'URL de l'application Mario** 
Votre application Mario est déployée sur le cluster K3d. Pour obtenir votre URL cliquez sur l'onglet **[PORTS]** dans votre Codespace et rendez public votre port **8080** (Visibilité du port).
Ouvrez l'URL dans votre navigateur et jouer !

---------------------------------------------------
Séquence 3 : Exercice
---------------------------------------------------
Objectif : Customisez un image Docker avec Packer et déploiement sur K3d via Ansible
Difficulté : Moyen/Difficile (~2h)
---------------------------------------------------  
Votre mission (si vous l'acceptez) : Créez une **image applicative customisée à l'aide de Packer** (Image de base Nginx embarquant le fichier index.html présent à la racine de ce Repository), puis déployer cette image customisée sur votre **cluster K3d** via **Ansible**, le tout toujours dans **GitHub Codespace**.  

**Architecture cible :** Ci-dessous, l'architecture cible souhaitée.   
  
![Screenshot Actions](Architecture_cible.png)   
  
---------------------------------------------------  
## Processus de travail (résumé)

1. Installation du cluster Kubernetes K3d (Séquence 1)
2. Installation de Packer et Ansible
3. Build de l'image customisée (Nginx + index.html)
4. Import de l'image dans K3d
5. Déploiement du service dans K3d via Ansible
6. Ouverture des ports et vérification du fonctionnement

---------------------------------------------------
Séquence 4 : Documentation  
Difficulté : Facile (~30 minutes)
---------------------------------------------------
**Complétez et documentez ce fichier README.md** pour nous expliquer comment utiliser votre solution.  
Faites preuve de pédagogie et soyez clair dans vos expliquations et processus de travail.  
   
---------------------------------------------------
## Solution implémentée
---------------------------------------------------

### 📁 Structure du projet

```
Image_to_Cluster/
├── index.html              # Page HTML personnalisée (SVG d'une maison)
├── Makefile                # Automatisation complète du projet
├── README.md               # Documentation
├── packer/
│   └── nginx.pkr.hcl       # Configuration Packer pour l'image Docker
└── ansible/
    ├── ansible.cfg         # Configuration Ansible
    ├── playbook.yml        # Playbook de déploiement K8s
    └── requirements.yml    # Dépendances Ansible
```

### 🚀 Déploiement rapide (One-liner)

```bash
make all
```

Cette commande exécute automatiquement :
1. Installation de K3d, Packer et Ansible
2. Création du cluster K3d (1 master + 2 workers)
3. Build de l'image Docker avec Packer
4. Import de l'image dans K3d
5. Déploiement sur Kubernetes via Ansible

### 📋 Déploiement étape par étape

#### 1. Installation des outils

```bash
make install-tools
```

Installe K3d, Packer et Ansible avec leurs dépendances.

#### 2. Création du cluster K3d

```bash
make cluster
```

Crée un cluster Kubernetes léger avec 1 master et 2 workers.

Vérification :
```bash
kubectl get nodes
```

#### 3. Build de l'image avec Packer

```bash
make packer-init
make packer-build
```

Construit une image Docker `nginx-custom:latest` basée sur `nginx:alpine` contenant le fichier `index.html`.

#### 4. Import de l'image dans K3d

```bash
make import-image
```

Importe l'image Docker locale dans le registre interne de K3d.

#### 5. Déploiement avec Ansible

```bash
make ansible-setup
make deploy
```

Déploie l'application sur Kubernetes :
- Deployment avec 2 replicas
- Service de type NodePort

#### 6. Accès à l'application

```bash
make port-forward
```

L'application est accessible sur `http://localhost:8080`.

Dans GitHub Codespace, ouvrez l'onglet **[PORTS]** et rendez le port **8080** public pour accéder à l'application depuis votre navigateur.

### 🛠️ Commandes Makefile disponibles

| Commande | Description |
|----------|-------------|
| `make all` | Installation et déploiement complet |
| `make help` | Affiche l'aide |
| `make install-tools` | Installe K3d, Packer et Ansible |
| `make cluster` | Crée le cluster K3d |
| `make cluster-delete` | Supprime le cluster K3d |
| `make cluster-status` | Affiche le statut du cluster |
| `make packer-init` | Initialise Packer |
| `make packer-build` | Construit l'image Docker |
| `make packer-validate` | Valide la configuration Packer |
| `make import-image` | Importe l'image dans K3d |
| `make ansible-setup` | Configure Ansible |
| `make deploy` | Déploie l'application |
| `make undeploy` | Supprime le déploiement |
| `make port-forward` | Expose l'application |
| `make stop-forward` | Arrête le port-forward |
| `make clean` | Nettoie tout |

### 🔧 Configuration Packer

Le fichier `packer/nginx.pkr.hcl` utilise le builder Docker pour :
- Partir de l'image `nginx:alpine`
- Copier `index.html` dans `/usr/share/nginx/html/`
- Tagger l'image comme `nginx-custom:latest`

### 📦 Playbook Ansible

Le fichier `ansible/playbook.yml` utilise la collection `kubernetes.core` pour :
- Créer un Deployment Kubernetes avec 2 replicas
- Créer un Service NodePort exposant le port 80
- L'option `imagePullPolicy: Never` permet d'utiliser l'image locale importée

### 🔍 Vérification du déploiement

```bash
# Vérifier les pods
kubectl get pods

# Vérifier les services
kubectl get svc

# Voir les logs d'un pod
kubectl logs -l app=nginx-custom
```

### 🧹 Nettoyage

Pour supprimer l'ensemble du déploiement :
```bash
make clean
```

---------------------------------------------------
Evaluation
---------------------------------------------------
Cet atelier, **noté sur 20 points**, est évalué sur la base du barème suivant :  
- Repository exécutable sans erreur majeure (4 points)
- Fonctionnement conforme au scénario annoncé (4 points)
- Degré d'automatisation du projet (utilisation de Makefile ? script ? ...) (4 points)
- Qualité du Readme (lisibilité, erreur, ...) (4 points)
- Processus travail (quantité de commits, cohérence globale, interventions externes, ...) (4 points) 


