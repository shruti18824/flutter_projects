from config import Settings
from tavily import TavilyClient
import trafilatura

settings = Settings()
tavily_client = TavilyClient(api_key=settings.TAVILY_API_KEY)


class SearchService:
    async def web_search(self, query: str):
        try:
            results = []
            response = tavily_client.search(query, max_results=10, include_images=True)
            search_results = response.get("results", [])
            images = response.get("images", [])

            # Define a helper function for processing a single result
            def process_result(result):
                try:
                    downloaded = trafilatura.fetch_url(result.get("url"))
                    content = trafilatura.extract(downloaded, include_comments=False)
                    return {
                        "title": result.get("title", ""),
                        "url": result.get("url", ""),
                        "content": content or "",
                    }
                except Exception:
                    return None

            # Use ThreadPoolExecutor to run blocking I/O tasks in parallel
            import asyncio
            from concurrent.futures import ThreadPoolExecutor
            
            loop = asyncio.get_running_loop()
            with ThreadPoolExecutor() as executor:
                tasks = [
                    loop.run_in_executor(executor, process_result, result)
                    for result in search_results
                ]
                processed_results = await asyncio.gather(*tasks)

            # Filter out None results (failed fetches)
            results = [res for res in processed_results if res]

            return results, images
        except Exception as e:
            print(e)
            return [], []