import firebase_admin
from firebase_admin import credentials, firestore
import random

# Inicializar Firebase
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)

db = firestore.client()

# Borrar colecciones previas (rutas y reseñas)
def borrar_coleccion(coleccion):
    docs = db.collection(coleccion).stream()
    for doc in docs:
        doc.reference.delete()
    print(f"🗑️ Colección '{coleccion}' borrada.")

borrar_coleccion("rutas")
borrar_coleccion("resenas")

# Datos de rutas con coordenadas reales
rutas = [
    {
        "nombre": "Ruta 1",
        "paradas": [
            {"id": "centro", "nombre": "Centro", "lat": 20.1217, "lng": -98.7333},
            {"id": "plaza_bella", "nombre": "Plaza Bella", "lat": 20.1017, "lng": -98.7511},
            {"id": "tuzos", "nombre": "Tuzos", "lat": 20.0895, "lng": -98.7631}
        ]
    },
    {
        "nombre": "Ruta 2",
        "paradas": [
            {"id": "issste", "nombre": "Hospital ISSSTE", "lat": 20.1139, "lng": -98.7426},
            {"id": "revolucion", "nombre": "Revolución", "lat": 20.1082, "lng": -98.7445},
            {"id": "uaeh", "nombre": "UAEH", "lat": 20.0793, "lng": -98.7093}
        ]
    },
    {
        "nombre": "Ruta 3",
        "paradas": [
            {"id": "real_de_minas", "nombre": "Real de Minas", "lat": 20.1343, "lng": -98.7257},
            {"id": "benito_juarez", "nombre": "Benito Juárez", "lat": 20.1225, "lng": -98.7302},
            {"id": "hospital_general", "nombre": "Hospital General", "lat": 20.1089, "lng": -98.7393}
        ]
    },
    {
        "nombre": "Ruta 4",
        "paradas": [
            {"id": "cubitos", "nombre": "Cubitos", "lat": 20.1381, "lng": -98.7305},
            {"id": "parque_hidalgo", "nombre": "Parque Hidalgo", "lat": 20.1291, "lng": -98.7357},
            {"id": "centro", "nombre": "Centro", "lat": 20.1217, "lng": -98.7333}
        ]
    },
    {
        "nombre": "Ruta 5",
        "paradas": [
            {"id": "matilde", "nombre": "Matilde", "lat": 20.0677, "lng": -98.7591},
            {"id": "imss", "nombre": "IMSS", "lat": 20.0869, "lng": -98.7467},
            {"id": "mercado", "nombre": "Mercado 1º de mayo", "lat": 20.1131, "lng": -98.7364}
        ]
    }
]

# Subir rutas con paradas
for ruta in rutas:
    doc_ref = db.collection("rutas").document()
    doc_ref.set({
        "nombre": ruta["nombre"],
        "paradas": ruta["paradas"]
    })

print("✅ Rutas subidas correctamente.")

# Subir reseñas asociadas a cada parada
autores = ["Ana", "Luis", "María", "Pedro", "Lucía"]
comentarios = [
    "Muy limpia la parada",
    "Buena ubicación",
    "Podría mejorar la iluminación",
    "Hay sombra, está bien",
    "Algo sucia pero funcional"
]

# Recopilar todas las paradas para agregarles reseñas
paradas_totales = []
for ruta in rutas:
    paradas_totales.extend(ruta["paradas"])

for parada in paradas_totales:
    for _ in range(3):  # 3 reseñas por parada
        db.collection("resenas").add({
            "paradaId": parada["id"],
            "autor": random.choice(autores),
            "estrellas": random.randint(1, 5),
            "comentario": random.choice(comentarios)
        })

print("⭐ Reseñas agregadas exitosamente.")
