# ----------------------------------------------------
# STAGE 1: Base Image (Runtime)
# Utilisation de l'image officielle Python 3.9 slim pour un runtime minimal
FROM python:3.9-slim

# Met à jour les packages de base (bonne pratique)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Définit le répertoire de travail dans le conteneur
WORKDIR /app

# ----------------------------------------------------
# Installation des dépendances
# Copie uniquement le fichier requirements.txt
COPY requirements.txt .

# Installe les dépendances en utilisant le cache Docker (meilleure pratique)
# Ceci est un layer séparé pour optimiser le rebuild si seul le code change.
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# ----------------------------------------------------
# Copie du code de l'application
# Copie l'intégralité du reste du code de l'application dans le conteneur
COPY . .

# La création du dossier 'models' n'est nécessaire que si train.py ne la gère pas
# Le mode d'exécution par défaut sera le point d'entrée de l'application.
# Si l'image est utilisée pour l'inférence, utilisez CMD ["python", "src/app.py"]
# Pour la CI/CD (comme demandé) :
# Nous faisons le train.py lors du build, donc le CMD devrait être pour l'inférence.
# Cependant, si vous utilisez cette image pour exécuter l'entraînement sur un runner
# (comme cela semble être le cas), c'est une approche acceptable.

# Commande par défaut pour l'exécution du conteneur (entraîne le modèle)
CMD ["python", "src/train.py"]