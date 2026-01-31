import asyncio
from fastapi import FastAPI, WebSocket

from pydantic_models.chat_body import ChatBody
from services.llm_service import LLMService
from services.sort_source_service import SortSourceService
from services.search_service import SearchService


app = FastAPI()

search_service = SearchService()
sort_source_service = SortSourceService()
llm_service = LLMService()


# chat websocket
@app.websocket("/ws/chat")
async def websocket_chat_endpoint(websocket: WebSocket):
    await websocket.accept()
    print("WebSocket connection accepted")

    try:
        while True:
            raw = await websocket.receive_text()
            print("Raw message:", raw)

            import json
            data = json.loads(raw)

            query = data.get("query")
            if not query:
                await websocket.send_json({
                    "type": "error",
                    "data": "Query missing"
                })
                continue

            print("Query:", query)

            search_results = search_service.web_search(query)
            sorted_results = sort_source_service.sort_sources(
                query, search_results
            )[:5]

            await websocket.send_json({
                "type": "search_result",
                "data": sorted_results
            })

            for chunk in llm_service.generate_response(query, sorted_results):
                await websocket.send_json({
                    "type": "content",
                    "data": chunk
                })

            await websocket.send_json({
                "type": "done"
            })

            print("Finished sending all chunks")

    except Exception as e:
        print("WebSocket error:", e)


# chat
@app.post("/chat")
def chat_endpoint(body: ChatBody):
    search_results = search_service.web_search(body.query)

    sorted_results = sort_source_service.sort_sources(body.query, search_results)

    response = llm_service.generate_response(body.query, sorted_results)

    return response