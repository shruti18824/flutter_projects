from google.genai import Client
from config import Settings

settings = Settings()
client = Client(api_key=settings.GEMINI_API_KEY)

# Retrieve all models
pager = client.models.list()

print("Available models:")

for model in pager:
    print("-" * 40)
    print("Model object:", model)        # print full object for inspection
    # Safe way to get known attributes
    print("Model name:", getattr(model, "name", "N/A"))
    print("ID:", getattr(model, "id", "N/A"))
    print("Description:", getattr(model, "description", "N/A"))
    print("Other fields:", {k: v for k, v in model.dict().items() if k not in ["id", "name", "description"]})
