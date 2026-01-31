from google.genai import Client
from config import Settings

settings = Settings()

class LLMService:
    def __init__(self):
        self.client = Client(api_key=settings.GEMINI_API_KEY)
        self.model_name = "gemini-2.5-flash-lite"  # stable & widely supported

    def generate_response(self, query: str, search_results: list[dict]):
        context_text = "\n\n".join(
            f"Source {i+1} ({r['url']}):\n{r['content']}"
            for i, r in enumerate(search_results)
        )

        full_prompt = f"""
        Context from web search:
        {context_text}

        Query: {query}

        Please provide a comprehensive, detailed point-wise accurate response using the above context. 
        Think and reason deeply. Ensure it answers the query the user is asking. Do not use your knowledge until it is absolutely necessary.
        Formatting Instructions:
        - Use Markdown syntax.
        - Use **bold** for key terms.
        - Use '##' for section headers.
        - Use '-' for bullet points.
        - If the context is insufficient, say so politely.
        """

        try:
            response = self.client.models.generate_content(
                model=self.model_name,
                contents=full_prompt
            )

            # response could be a tuple, list, or single object
            if isinstance(response, tuple) or isinstance(response, list):
                response_items = list(response)
            else:
                response_items = [response]

            # safely yield text from each item
            for item in response_items:
                if hasattr(item, "text"):
                    text = item.text
                elif isinstance(item, dict):
                    text = item.get("content", "")
                else:
                    text = str(item)

                # split by newlines or small chunks if needed
                for chunk in text.split("\n"):
                    yield chunk

        except Exception as e:
            # yield error info to frontend
            yield f"[Error generating response: {str(e)}]"
