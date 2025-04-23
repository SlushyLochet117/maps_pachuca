import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime

# Inicializar Firebase
cred = credentials.Certificate('firebase_key.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

# Lista de reseñas de prueba
reseñas = [
    {
        "paradaId": "parada1",
        "usuario": "Carlos H.",
        "comentario": "Muy limpia y bien ubicada.",
        "estrellas": 5,
        "fecha": datetime.now()
    },
    {
        "paradaId": "parada1",
        "usuario": "María P.",
        "comentario": "Hay sombra, eso se agradece.",
        "estrellas": 4,
        "fecha": datetime.now()
    },
    {
        "paradaId": "parada2",
        "usuario": "Luis M.",
        "comentario": "Un poco sucia, pero funcional.",
        "estrellas": 3,
        "fecha": datetime.now()
    },
    {
        "paradaId": "parada3",
        "usuario": "Ana G.",
        "comentario": "No tiene techo. Se moja uno si llueve.",
        "estrellas": 2,
        "fecha": datetime.now()
    },
]

# Subir cada reseña en la subcolección de cada parada
for resena in reseñas:
    parada_id = resena["paradaId"]
    resena_data = {
        "usuario": resena["usuario"],
        "comentario": resena["comentario"],
        "estrellas": resena["estrellas"],
        "fecha": resena["fecha"]
    }
    db.collection("paradas").document(parada_id).collection("resenas").add(resena_data)
    print(f"Reseña agregada a parada {parada_id}")
print("✅ Rutas subidas correctamente.")

