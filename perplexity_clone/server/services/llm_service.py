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
            # Use generate_content_stream for the new V1 SDK
            for chunk in self.client.models.generate_content_stream(
                model=self.model_name,
                contents=full_prompt,
            ):
                if hasattr(chunk, "text"):
                    yield chunk.text
                elif hasattr(chunk, "candidates") and chunk.candidates:
                     # Fallback for some structure variations
                     yield chunk.candidates[0].content.parts[0].text

        except Exception as e:
            # yield error info to frontend
            yield f"[Error generating response: {str(e)}]"
