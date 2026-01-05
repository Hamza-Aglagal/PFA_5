# 🐳 Guide Docker Compose - SimStruct

## 📋 État Actuel

Docker Compose est **en cours d'exécution** depuis ~11 minutes.

## 🔍 Vérifier l'État des Services

### Commande 1: Voir tous les conteneurs

```powershell
docker ps -a
```

**Vous devriez voir** :
- `simstruct-ai-model` (port 8000)
- `simstruct-backend` (port 8080)
- `simstruct-frontend` (port 4200)

### Commande 2: Voir les logs

```powershell
# Tous les services
docker-compose logs

# Service spécifique
docker-compose logs ai-model
docker-compose logs backend
docker-compose logs frontend

# Suivre les logs en temps réel
docker-compose logs -f
```

### Commande 3: Vérifier l'état

```powershell
docker-compose ps
```

## 🚀 Services Disponibles

Une fois que Docker Compose a terminé le build :

### 1. **API du Modèle AI**
- **URL** : http://localhost:8000
- **Swagger** : http://localhost:8000/docs
- **Health** : http://localhost:8000/health

**Test rapide** :
```powershell
curl http://localhost:8000/health
```

### 2. **Backend Spring Boot**
- **URL** : http://localhost:8080
- **API** : http://localhost:8080/api/v1
- **Health** : http://localhost:8080/actuator/health

**Test rapide** :
```powershell
curl http://localhost:8080/actuator/health
```

### 3. **Frontend Angular**
- **URL** : http://localhost:4200
- **Application** : Ouvrir dans le navigateur

**Test rapide** :
```powershell
# Ouvrir dans le navigateur
start http://localhost:4200
```

## 🧪 Exécuter les Tests

### Une fois les services démarrés

#### 1. Tests Backend API

```powershell
cd Tests_Selenium\Backend_SpringBoot
mvn test
```

#### 2. Tests AI Model

```powershell
cd Tests_Selenium\AI_Model
pip install -r requirements_professional.txt
pytest test_ai_professional.py -v
```

#### 3. Tests Frontend (si Node.js compatible)

```powershell
cd Tests_Selenium\Frontend_Angular
mvn test
```

## 📊 Vérification Rapide

### Script PowerShell de Vérification

```powershell
# Vérifier si les services répondent
Write-Host "🔍 Vérification des services..." -ForegroundColor Cyan

# AI Model
try {
    $ai = Invoke-WebRequest -Uri "http://localhost:8000/health" -UseBasicParsing -TimeoutSec 2
    Write-Host "✅ AI Model: OK (port 8000)" -ForegroundColor Green
} catch {
    Write-Host "❌ AI Model: Non disponible" -ForegroundColor Red
}

# Backend
try {
    $backend = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -UseBasicParsing -TimeoutSec 2
    Write-Host "✅ Backend: OK (port 8080)" -ForegroundColor Green
} catch {
    Write-Host "❌ Backend: Non disponible" -ForegroundColor Red
}

# Frontend
try {
    $frontend = Invoke-WebRequest -Uri "http://localhost:4200" -UseBasicParsing -TimeoutSec 2
    Write-Host "✅ Frontend: OK (port 4200)" -ForegroundColor Green
} catch {
    Write-Host "❌ Frontend: Non disponible" -ForegroundColor Red
}
```

## 🛠️ Commandes Utiles

### Arrêter les services

```powershell
docker-compose down
```

### Redémarrer un service spécifique

```powershell
docker-compose restart ai-model
docker-compose restart backend
docker-compose restart frontend
```

### Voir les ressources utilisées

```powershell
docker stats
```

### Nettoyer et reconstruire

```powershell
docker-compose down
docker-compose up -d --build
```

## 🐛 Dépannage

### Problème 1: Service ne démarre pas

```powershell
# Voir les logs d'erreur
docker-compose logs <service-name>

# Exemple
docker-compose logs backend
```

### Problème 2: Port déjà utilisé

```powershell
# Trouver le processus sur le port
netstat -ano | findstr :8000
netstat -ano | findstr :8080
netstat -ano | findstr :4200

# Tuer le processus
taskkill /PID <PID> /F
```

### Problème 3: Build échoue

```powershell
# Nettoyer tout
docker-compose down -v
docker system prune -a

# Reconstruire
docker-compose up -d --build
```

## 📈 Temps de Démarrage Estimé

- **AI Model** : ~2-3 minutes
- **Backend** : ~3-4 minutes
- **Frontend** : ~2-3 minutes

**Total** : ~8-10 minutes pour le premier build

## ✅ Checklist de Vérification

Après ~10-15 minutes, vérifiez :

- [ ] `docker ps` montre 3 conteneurs en cours d'exécution
- [ ] http://localhost:8000/health retourne `{"status": "healthy"}`
- [ ] http://localhost:8080/actuator/health retourne `{"status": "UP"}`
- [ ] http://localhost:4200 affiche l'application Angular
- [ ] Aucune erreur dans `docker-compose logs`

## 🎯 Prochaines Étapes

Une fois que tous les services sont UP :

1. **Tester l'API AI** :
   ```powershell
   cd Tests_Selenium\AI_Model
   pytest test_ai_professional.py -v
   ```

2. **Tester le Backend** :
   ```powershell
   cd Tests_Selenium\Backend_SpringBoot
   mvn test
   ```

3. **Ouvrir l'application** :
   ```powershell
   start http://localhost:4200
   ```

## 📝 Notes

- Les services peuvent prendre jusqu'à 15 minutes pour le premier démarrage
- Les logs sont disponibles avec `docker-compose logs -f`
- Pour arrêter : `docker-compose down`
- Pour redémarrer : `docker-compose restart`

---

**🐳 Votre environnement Docker est en cours de démarrage ! Patience... ⏳**
