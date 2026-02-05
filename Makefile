# ============================================
# Makefile - Image to Cluster Automation
# ============================================

.PHONY: all clean help

# Variables
CLUSTER_NAME ?= lab
IMAGE_NAME ?= nginx-custom
IMAGE_TAG ?= latest
LOCAL_PORT ?= 8080

## all: Installation complète et déploiement
all:
    @echo "=== Installation des outils ==="
    @curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
    @if ! which packer > /dev/null 2>&1; then \
        curl -fsSL https://releases.hashicorp.com/packer/1.10.3/packer_1.10.3_linux_amd64.zip -o /tmp/packer.zip && \
        unzip -o /tmp/packer.zip -d /tmp && \
        sudo mv /tmp/packer /usr/local/bin/; \
    fi
    @pip install --quiet ansible kubernetes
    @ansible-galaxy collection install -r ansible/requirements.yml --force
    @echo "=== Création du cluster K3d ==="
    @k3d cluster create $(CLUSTER_NAME) --servers 1 --agents 2 2>/dev/null || echo "Cluster existe déjà"
    @kubectl get nodes
    @echo "=== Build de l'image avec Packer ==="
    @cd packer && packer init nginx.pkr.hcl && packer build nginx.pkr.hcl
    @echo "=== Import de l'image dans K3d ==="
    @k3d image import $(IMAGE_NAME):$(IMAGE_TAG) -c $(CLUSTER_NAME)
    @echo "=== Déploiement avec Ansible ==="
    @cd ansible && ansible-playbook playbook.yml
    @kubectl get pods
    @kubectl get svc
    @echo "=== Exposition de l'application ==="
    @pkill -f "port-forward svc/$(IMAGE_NAME)" 2>/dev/null || true
    @kubectl port-forward svc/$(IMAGE_NAME) $(LOCAL_PORT):80 >/tmp/nginx-custom.log 2>&1 &
    @echo ""
    @echo "✅ Déploiement terminé !"
    @echo "Application accessible sur http://localhost:$(LOCAL_PORT)"
    @echo "Ouvrez l'onglet PORTS et rendez le port $(LOCAL_PORT) public"

## clean: Nettoie tout
clean:
    @echo "=== Nettoyage ==="
    @pkill -f "port-forward svc/$(IMAGE_NAME)" 2>/dev/null || true
    @kubectl delete deployment $(IMAGE_NAME) --ignore-not-found 2>/dev/null || true
    @kubectl delete service $(IMAGE_NAME) --ignore-not-found 2>/dev/null || true
    @k3d cluster delete $(CLUSTER_NAME) 2>/dev/null || true
    @docker rmi $(IMAGE_NAME):$(IMAGE_TAG) 2>/dev/null || true
    @echo "✅ Nettoyage terminé"

## help: Affiche l'aide
help:
    @echo "Commandes disponibles:"
    @echo "  make all   - Installation complète et déploiement"
    @echo "  make clean - Supprime tout (cluster, images, déploiement)"
    @echo "  make help  - Affiche cette aide"
