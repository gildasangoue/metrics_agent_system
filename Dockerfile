#=================================
# My Dockerfile for building a Python application
#=================================

# ÉTAPE 1 : Le Stage de Build
FROM python:3.12-alpine AS builder

WORKDIR /app

# Ajout de build-essential au cas où certaines bibliothèques Python
# auraient besoin de compiler du code C pendant le pip install
RUN apk add --no-cache build-base

COPY requirements.txt .
# CORRECTION : Ajout de --user pour forcer l'installation dans /root/.local
RUN pip install --no-cache-dir --user -r requirements.txt


# ÉTAPE 2 : Le Stage Final (Production)
FROM python:3.12-alpine AS runner

WORKDIR /app

RUN apk add --no-cache procps

# Création du groupe et de l'utilisateur sécurisé
RUN addgroup -S devopsecure && adduser -S -G devopsecure devopsuser

# Récupération des dépendances proprement isolées du stage builder
COPY --from=builder /root/.local /home/devopsuser/.local
COPY . .

# Sécurisation des permissions des fichiers pour notre utilisateur non-root
RUN chown -R devopsuser:devopsecure /app
ENV PATH=/home/devopsuser/.local/bin:$PATH
USER devopsuser

# Vérification de l'état de santé de l'API
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health', timeout=3)" || exit 1

EXPOSE 8000
CMD ["uvicorn", "app.api:app", "--host", "0.0.0.0", "--port", "8000"]
