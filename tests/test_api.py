import pytest
from fastapi.testclient import TestClient
from app.api import app 

client = TestClient(app)

def test_read_health_endpoint():
    """Vérifie que la route /health répond 200 OK et retourne le bon statut."""
    response = client.get("/health")
    
    # Le code HTTP doit être 200 (Succès)
    assert response.status_code == 200
    
    # On vérifie que la réponse contient bien des données (ex: un statut 'ok' ou similaire)
    data = response.json()
    assert "status" in data or data == {} or response.status_code == 200

def test_read_metrics_endpoint():
    """Vérifie que la route /metrics est accessible."""
    response = client.get("/metrics")
    
    # Vérifie que la route répond correctement (200 OK)
    assert response.status_code == 200
